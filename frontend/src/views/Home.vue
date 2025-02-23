<template>
    <div class="container mt-5">
      <h2>Home</h2>
      <p>Welcome to the ERP system!</p>
      <button @click="handleLogout" class="btn btn-danger">Logout</button>
    </div>
  </template>
  
  <script>
  export default {
    name: 'Home',
    methods: {
      handleLogout() {
        localStorage.removeItem('access_token')
        this.$router.push('/login')
      }
    }
  }
  </script>
  
  <style scoped>
  /* Optional component styles */
  </style>
  