// server.js
const { ApolloServer, gql } = require('apollo-server');

// 1. 定义GraphQL Schema
const typeDefs = gql`
  type User {
    id: ID!
    name: String!
    email: String!
    age: Int
    posts: [Post!]!
  }

  type Post {
    id: ID!
    title: String!
    content: String!
    published: Boolean!
    author: User!
  }

  type Query {
    users: [User!]!
    user(id: ID!): User
    posts: [Post!]!
    post(id: ID!): Post
  }

  type Mutation {
    createUser(name: String!, email: String!, age: Int): User!
    createPost(title: String!, content: String!, authorId: ID!): Post!
    updateUser(id: ID!, name: String, email: String, age: Int): User!
    deleteUser(id: ID!): Boolean!
  }
`;

// 2. 模拟数据
let users = [
  { id: '1', name: 'Alice', email: 'alice@example.com', age: 25 },
  { id: '2', name: 'Bob', email: 'bob@example.com', age: 30 },
];

let posts = [
  { id: '1', title: 'GraphQL Introduction', content: 'Learn GraphQL basics', published: true, authorId: '1' },
  { id: '2', title: 'Advanced GraphQL', content: 'Deep dive into GraphQL', published: false, authorId: '2' },
];

// 3. 解析器函数
const resolvers = {
  Query: {
    users: () => users,
    user: (parent, args) => users.find(user => user.id === args.id),
    posts: () => posts,
    post: (parent, args) => posts.find(post => post.id === args.id),
  },
  
  Mutation: {
    createUser: (parent, args) => {
      const newUser = {
        id: String(users.length + 1),
        ...args
      };
      users.push(newUser);
      return newUser;
    },
    
    createPost: (parent, args) => {
      const newPost = {
        id: String(posts.length + 1),
        published: false,
        ...args
      };
      posts.push(newPost);
      return newPost;
    },
    
    updateUser: (parent, args) => {
      const userIndex = users.findIndex(user => user.id === args.id);
      if (userIndex === -1) throw new Error('User not found');
      
      users[userIndex] = {
        ...users[userIndex],
        ...args
      };
      return users[userIndex];
    },
    
    deleteUser: (parent, args) => {
      const userIndex = users.findIndex(user => user.id === args.id);
      if (userIndex === -1) return false;
      
      users.splice(userIndex, 1);
      return true;
    }
  },
  
  // 解析字段间的关系
  User: {
    posts: (parent) => posts.filter(post => post.authorId === parent.id)
  },
  
  Post: {
    author: (parent) => users.find(user => user.id === parent.authorId)
  }
};

// 4. 创建和启动服务器
const server = new ApolloServer({
  typeDefs,
  resolvers,
  playground: true // 启用GraphQL Playground
});

server.listen({ port: 4000 }).then(({ url }) => {
  console.log(`🚀 Server ready at ${url}`);
});
