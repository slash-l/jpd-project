const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 3001;

// 中间件
app.use(cors());
app.use(express.json());

// 模拟数据
const users = [
  { id: 1, name: '张三', email: 'zhangsan@example.com' },
  { id: 2, name: '李四', email: 'lisi@example.com' },
  { id: 3, name: '王五', email: 'wangwu@example.com' }
];

// 路由
app.get('/', (req, res) => {
  res.json({ 
    message: '后端 API 服务运行正常！',
    timestamp: new Date().toISOString()
  });
});

// 获取所有用户
app.get('/api/users', (req, res) => {
  res.json({
    success: true,
    data: users,
    count: users.length
  });
});

// 根据ID获取用户
app.get('/api/users/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const user = users.find(u => u.id === id);
  
  if (user) {
    res.json({ success: true, data: user });
  } else {
    res.status(404).json({ success: false, message: '用户未找到' });
  }
});

// 添加新用户
app.post('/api/users', (req, res) => {
  const { name, email } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({ 
      success: false, 
      message: '姓名和邮箱不能为空' 
    });
  }
  
  const newUser = {
    id: users.length + 1,
    name,
    email
  };
  
  users.push(newUser);
  
  res.json({ 
    success: true, 
    message: '用户添加成功',
    data: newUser 
  });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`后端服务运行在 http://localhost:${PORT}`);
  console.log(`API 文档:`);
  console.log(`- GET  /              : 服务状态`);
  console.log(`- GET  /api/users     : 获取所有用户`);
  console.log(`- GET  /api/users/:id : 根据ID获取用户`);
  console.log(`- POST /api/users     : 添加新用户`);
});
