<template>
  <div>
    <h1>Total de Ofertas</h1>

    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">


        <div class="filters-bar">
      <div class="block">
        <el-select
          v-model="value"
          placeholder="Seleccione un Filtro"
          @change="handleChange"
          class="filter-select"
        >
          <el-option
            v-for="option in options"
            :key="option.value"
            :label="option.label"
            :value="option.value"
          />
        </el-select>
      </div>

      <el-input
        v-if="value && !isDateFilter"
        type="text"
        placeholder="Ingresé el valor a buscar ..."
        v-model="searchQuery"
        size="small"
        class="filter-input"
      />

      <el-button
        @click="search"
        size="small"
        style="white-space: nowrap; margin-right: 8px"
      >
        Buscar
      </el-button>
      <el-button
        @click="clearFilters"
        size="small"
        type="info"
        style="white-space: nowrap"
      >
        Limpiar
      </el-button>
      
      <el-button
        @click="exportToExcel"
        size="small"
        icon="el-icon-document"
        type="success"
        style="white-space: nowrap"
      >
        Generar Excel
      </el-button>
    </div>
    <div style="display: flex; justify-content:flex-end; margin: 20px;">
        <el-button type="primary" icon="el-icon-plus" @click="openCreateOfferModal">
          Crear Oferta
        </el-button>
    </div>
  </div>


    <el-table :data="offers" style="width: 100%; margin-bottom: 24px">
      <el-table-column prop="consecutivo" label="Consecutivo" width="180" />
      <el-table-column prop="objeto" label="Objeto" width="180" />
      <el-table-column prop="descripcion" label="Descripcion" width="180" />
      <el-table-column prop="fecha_inicio" label="Fecha de inicio" width="180" />
      <el-table-column prop="fecha_cierre" label="Fecha de cierre" width="180" />
      <el-table-column prop="estado" label="Estado" />
      <el-table-column label="Acciones" width="200">
        <template #default="scope">
          <el-button
            icon="el-icon-view"
            size="mini"
            @click="viewOffer(scope.row)"
            title="Ver oferta"
          >
          </el-button>
          <el-button
            icon="el-icon-edit"
            size="mini"
            type="primary"
            @click="editOffer(scope.row)"
          >
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    <div style="display: flex; justify-content: flex-end; padding: 16px 0">
      <el-pagination
        background
        layout="prev, pager, next"
        :total="count"
        :page-size="limit"
        :current-page="currentPage"
        @current-change="handlePageChange"
        :hide-on-single-page="true"
      />
    </div>

    <create-offer-modal 
      :visible="isCreateOfferModalVisible" 
      :mode.sync="modalMode" 
      :offer="selectedOffer" 
      @close="isCreateOfferModalVisible = false"       
      @created="handleOfferCreated"
    />
    <view-offer-modal
      v-if="isViewOfferModalVisible"
      :visible.sync="isViewOfferModalVisible"
      :offer="selectedOffer"
      @close="isViewOfferModalVisible = false"
      ref="viewOfferModal"
      @edit="openEditModal"

    />
    <edit-offer-modal
      v-if="isEditOfferModalVisible"
      ref="editOfferModal"
      :visible.sync="isEditOfferModalVisible"
      :offer-id="selectedOfferId"
    />
  </div>
</template>

<script>
import CreateOfferModal from "./CreateOfferModal.vue";
import ViewOfferModal from "./ViewOfferModal.vue";
import EditOfferModal from "./EditOfferModal.vue";

export default {
  name: "RegisterTable",
  components: {
    CreateOfferModal,
    ViewOfferModal,
    EditOfferModal
  },
  computed: {
    isDateFilter() {
      return this.value === "date";
    },
  },
  data() {
    return {
      offers: [],
      count: 0,
      limit: 15, // Updated to match "per_page" from the response
      currentPage: 1,
      value: "",
      value1: "",
      searchQuery: "",
      options: [
        {
          value: "consecutivo",
          label: "Consecutivo",
        },
        {
          value: "objeto",
          label: "Objeto",
        },
        {
          value: "descripcion",
          label: "Descripcion",
        }
      ],
      isCreateOfferModalVisible: false,
      isViewOfferModalVisible: false,
      isEditOfferModalVisible: false,
      selectedOfferId: '',
      modalMode: "create",
      selectedOffer: null,
      exporting: false,
    };
  },
  methods: {
    async fetchOffers(page = 1) {
      this.loading = true;
      try {
        const url = `${API_BASE_URL}/ofertas?page=${page}&limit=${this.limit}`;
        const res = await fetch(url);
        if (!res.ok) throw new Error("Error al obtener ofertas");
        const data = await res.json();

        // Adjusted to handle the new response structure
        this.offers = data.data;
        this.count = data.meta.total;
        this.currentPage = data.meta.current_page;
      } catch (err) {
        console.error("Error al obtener ofertas:", err);
        this.$message && this.$message.error("Error al obtener ofertas");
        this.offers = [];
        this.count = 0;
      } finally {
        this.loading = false;
      }
    },
    handlePageChange(page) {
      this.currentPage = page;
      this.fetchOffers(page);
    },
    async search() {
      // Validar que se haya seleccionado un filtro
      if (!this.value) {
        this.$message && this.$message.warning("Por favor selecciona un filtro");
        return;
      }

      // Validar que haya texto para buscar (solo si no es filtro de fecha)
      if (!this.isDateFilter && (!this.searchQuery || !this.searchQuery.trim())) {
        this.$message && this.$message.warning("Por favor ingresa un valor para buscar");
        return;
      }

      this.loading = true;
      try {
        const params = new URLSearchParams({
          page: 1,
          limit: this.limit,
        });

        // Agregar el filtro dinámico: consecutivo=PO-001, objeto=equipos, etc.
        if (!this.isDateFilter) {
          params.append(this.value, this.searchQuery.trim());
        }
        // Si en el futuro implementas rango de fechas, aquí iría la lógica

        const url = `${API_BASE_URL}/ofertas?${params.toString()}`;
        const res = await fetch(url);
        if (!res.ok) throw new Error("Error al filtrar ofertas");

        const data = await res.json();
        this.offers = data.data || [];
        this.count = data.meta?.total || 0;
        this.currentPage = data.meta?.current_page || 1;

      } catch (err) {
        console.error("Error al filtrar ofertas:", err);
        this.$message && this.$message.error("Error al filtrar ofertas");
        this.offers = [];
        this.count = 0;
      } finally {
        this.loading = false;
      }
    },
    handleChange() {
      this.searchQuery = "";
      this.value1 = "";
    },
    clearFilters() {
      this.value = "";
      this.searchQuery = "";
      this.value1 = "";
      this.currentPage = 1;
      this.fetchOffers(1);
    },
    openCreateOfferModal() {
      this.isCreateOfferModalVisible = true;
      this.modalMode = "create";
      this.selectedOffer = null;
      this.$nextTick(() => {
        this.$refs.createOfferModal.form = {
          objeto: "",
          descripcion: "",
          moneda: "",
          presupuesto: null,
          actividad_id: null,
          fecha_inicio: "",
          hora_inicio: "",
          fecha_cierre: "",
          hora_cierre: "",
          consecutivo: "",
          estado: "",
        };
      });
    },
    handleOfferCreated() {
      // Recargar la página actual de ofertas
      this.fetchOffers(this.currentPage);
    },
    viewOffer(offer) {
      this.isViewOfferModalVisible = true;
      this.selectedOffer = offer;

      // Ensure the modal is visible before calling the method
      this.$nextTick(() => {
        if (this.$refs.viewOfferModal) {
          this.$refs.viewOfferModal.fetchOfferDetails(offer.id);
        } else {
          console.error("ViewOfferModal ref is undefined");
        }
      });
    },
    editOffer(offer) {
      this.selectedOfferId = offer.id;
      this.isEditOfferModalVisible = true;
      this.$nextTick(() => {
        if (this.$refs.editOfferModal) {
          this.$refs.editOfferModal.fetchOfferDetails(offer.id);
        }
      });
    },
    openEditModal(offerId) {
      if (!offerId) {
        console.error("ID de oferta no proporcionado para edición");
        return;
      }
      this.selectedOfferId = offerId;
      this.isViewOfferModalVisible = false;
      this.isEditOfferModalVisible = true;
    },
    exportToExcel() {
      this.exporting = true;

      // Construir parámetros de filtro (igual que en search())
      const params = new URLSearchParams();

      if (this.value && !this.isDateFilter && this.searchQuery?.trim()) {
        params.append(this.value, this.searchQuery.trim());
      }

      const url = `${API_BASE_URL}/ofertas/export?${params.toString()}`;

      // Abrir en nueva pestaña (dispara la descarga)
      window.open(url, '_blank');

      // Pequeño delay para que el loading se note (opcional)
      setTimeout(() => {
        this.exporting = false;
      }, 800);
    },
  },
  mounted() {
    this.fetchOffers(1);
  },
};
const API_BASE_URL = process.env.VUE_APP_API_BASE_URL;
</script>

<style lang="scss" scoped>
.filters-bar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  margin-bottom: 20px;
  margin: 10px;
}
.filter-input {
  min-width: 140px;
  max-width: 200px;
  flex: 1 1 140px;
  margin: 10px;
}
.filter-select {
  min-width: 180px;
  margin-right: 10px;
}
.filter-date {
  min-width: 300px;
  margin: 0 10px;
}
@media (max-width: 600px) {
  .filters-bar {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
}
.el-dropdown-link {
  cursor: pointer;
  color: #409eff;
}
.el-icon-arrow-down {
  font-size: 12px;
}
.demonstration {
  display: block;
  color: #8492a6;
  font-size: 14px;
  margin-bottom: 20px;
}
</style>
