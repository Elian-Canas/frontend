<template>
  <el-container style="height: 100vh">
    <el-header style="background: #1f2d3d; color: #fff; font-size: 30px">
      Licitación Dashboard
    </el-header>
    <el-container>
      <el-aside width="200px" style="background: #2d3a4b; color: #fff">
        <el-menu
          default-active="1"
          class="el-menu-vertical-demo"
          @select="handleSelect"
          background-color="#2d3a4b"
          text-color="#fff"
          active-text-color="#ffd04b"
        >
          <el-menu-item index="1">Ofertas</el-menu-item>
        </el-menu>
      </el-aside>
      <el-main>
        <RegisterTable v-if="currentView === '1'"></RegisterTable>
      </el-main>
    </el-container>
  </el-container>
</template>

<script>
import RegisterTable from "./RegisterTable.vue";

export default {
  name: "HelloWorld",
  components: {
    RegisterTable,
  },
  data() {
    return {
      currentView: "1",
    };
  },
  methods: {
    handleSelect(index) {
      this.currentView = index;
    },
  },
};
</script>

<style lang="scss" scoped>
.el-header {
  display: flex;
  align-items: center;
  height: 60px;
}
</style>

<style>
#app {
  margin-top: 0 !important;
}
</style>
