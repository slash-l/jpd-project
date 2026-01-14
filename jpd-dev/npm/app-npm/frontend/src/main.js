import axios from 'axios';

const API_BASE_URL = 'http://localhost:3001';

// 创建 axios 实例
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 5000,
});

// 更新状态显示
function updateStatus(message, isError = false) {
  const statusEl = document.getElementById('status');
  statusEl.textContent = message;
  statusEl.className = `status ${isError ? 'error' : 'connected'}`;
}

// 检查服务状态
window.checkStatus = async function() {
  const resultEl = document.getElementById('statusResult');
  resultEl.innerHTML = '<div class="loading">检查中...</div>';
  
  try {
    const response = await api.get('/');
    resultEl.innerHTML = `
      <div style="color: green;">
        <strong>✅ 服务正常</strong><br>
        消息: ${response.data.message}<br>
        时间: ${new Date(response.data.timestamp).toLocaleString()}
      </div>
    `;
  } catch (error) {
    resultEl.innerHTML = `
      <div style="color: red;">
        <strong>❌ 服务连接失败</strong><br>
        错误: ${error.message}
      </div>
    `;
  }
};

// 加载用户列表
window.loadUsers = async function() {
  const userListEl = document.getElementById('userList');
  userListEl.innerHTML = '<div class="loading">加载中...</div>';
  
  try {
    const response = await api.get('/api/users');
    const users = response.data.data;
    
    if (users.length === 0) {
      userListEl.innerHTML = '<li>暂无用户数据</li>';
      return;
    }
    
    userListEl.innerHTML = users.map(user => `
      <li class="user-item">
        <strong>ID: ${user.id}</strong><br>
        姓名: ${user.name}<br>
        邮箱: ${user.email}
      </li>
    `).join('');
  } catch (error) {
    userListEl.innerHTML = `<li style="color: red;">加载失败: ${error.message}</li>`;
  }
};

// 添加新用户
window.addUser = async function() {
  const name = document.getElementById('userName').value.trim();
  const email = document.getElementById('userEmail').value.trim();
  const resultEl = document.getElementById('addUserResult');
  
  if (!name || !email) {
    resultEl.innerHTML = '<div style="color: red;">请填写姓名和邮箱</div>';
    return;
  }
  
  resultEl.innerHTML = '<div class="loading">添加中...</div>';
  
  try {
    const response = await api.post('/api/users', { name, email });
    
    if (response.data.success) {
      resultEl.innerHTML = '<div style="color: green;">✅ 用户添加成功！</div>';
      document.getElementById('userName').value = '';
      document.getElementById('userEmail').value = '';
      // 重新加载用户列表
      loadUsers();
    }
  } catch (error) {
    resultEl.innerHTML = `<div style="color: red;">添加失败: ${error.response?.data?.message || error.message}</div>`;
  }
};

// 初始化检查连接
async function init() {
  try {
    await api.get('/');
    updateStatus('✅ 后端服务连接正常');
  } catch (error) {
    updateStatus('❌ 后端服务连接失败', true);
  }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', init);
