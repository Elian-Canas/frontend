<template>
  <div id="app">
    <Sidebar/>
  </div>
</template>

<script>
import Sidebar from './components/Sidebar.vue';

export default {
  name: 'App',
  components: {
    Sidebar
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
body {
  margin: 0 !important;
  padding: 0 !important;
}
</style>
