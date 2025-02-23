<template>
    <div class="container mt-5">
      <h2>Login</h2>
      <form @submit.prevent="handleLogin">
        <div class="mb-3">
          <label for="username" class="form-label">Username</label>
          <input v-model="username" type="text" class="form-control" id="username" required>
        </div>
        <div class="mb-3">
          <label for="password" class="form-label">Password</label>
          <input v-model="password" type="password" class="form-control" id="password" required>
        </div>
        <button type="submit" class="btn btn-primary">Login</button>
        <div v-if="error" class="mt-3 alert alert-danger">{{ error }}</div>
      </form>
    </div>
  </template>
  
  <script>
  import axios from 'axios'
  
  export default {
    name: 'Login',
    data() {
      return {
        username: '',
        password: '',
        error: ''
      }
    },
    methods: {
      async handleLogin() {
        try {
          const response = await axios.post(
            process.env.VUE_APP_API_URL + '/auth/login',
            {
              username: this.username,
              password: this.password
            }
          )
          // Save the token in localStorage
          localStorage.setItem('access_token', response.data.access_token)
          // Redirect to the home page
          this.$router.push('/home')
        } catch (err) {
          this.error = 'Invalid username or password'
          console.error(err)
        }
      }
    }
  }
  </script>
  
  <style scoped>
  /* Optional component styles */
  </style>
  