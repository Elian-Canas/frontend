<!-- EditOfferModal.vue -->
<template>
  <div>
      <el-dialog title="Editar Oferta" :visible.sync="localVisible" width="50%" @close="closeModal" append-to-body>
    <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
      <el-form-item label="Objeto" prop="objeto">
        <el-input v-model="form.objeto" maxlength="150" show-word-limit />
      </el-form-item>
      <el-form-item label="Descripción" prop="descripcion">
        <el-input v-model="form.descripcion" type="textarea" maxlength="400" show-word-limit />
      </el-form-item>
      <el-form-item label="Moneda" prop="moneda">
        <el-select v-model="form.moneda" placeholder="Seleccione">
          <el-option label="COP" value="COP" />
          <el-option label="USD" value="USD" />
          <el-option label="EUR" value="EUR" />
        </el-select>
      </el-form-item>
      <el-form-item label="Presupuesto" prop="presupuesto">
        <el-input v-model="form.presupuesto" type="number" min="0" step="0.01" />
      </el-form-item>
      <el-form-item label="Actividad" :label-width="formLabelWidth" prop="actividad_id">
        <el-select
          v-model="form.actividad_id"
          placeholder="Seleccione"
          filterable
          remote
          :remote-method="handleActividadSearch"
          :loading="loadingActividades"
        >
          <el-option
            v-for="actividad in actividades"
            :key="actividad.id"
            :label="actividad.producto"
            :value="actividad.id"
          />
        </el-select>
      </el-form-item>

      <h3 style="margin-top: 20px;">Cronograma</h3>
      <el-form-item label="Fecha Inicio" prop="fecha_inicio">
        <el-date-picker v-model="form.fecha_inicio" type="date" />
      </el-form-item>
      <el-form-item label="Hora Inicio" prop="hora_inicio">
        <el-time-picker v-model="form.hora_inicio" />
      </el-form-item>
      <el-form-item label="Fecha Cierre" prop="fecha_cierre">
        <el-date-picker v-model="form.fecha_cierre" type="date" />
      </el-form-item>
      <el-form-item label="Hora Cierre" prop="hora_cierre">
        <el-time-picker v-model="form.hora_cierre" />
      </el-form-item>
      <el-form-item label="Estado">
        <el-input v-model="form.estado" />
      </el-form-item>
      
      <div class="document-button-container">
        <el-button
          @click="openAddDocumentModal"
          size="small"
          icon="el-icon-document"
          type="info"
          style="white-space: nowrap"
        >
          Agregar documento
        </el-button>
      </div>

    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button @click="closeModal">Cancelar</el-button>
      <el-button type="primary" @click="submitForm">Actualizar</el-button>
    </div>

    
    </el-dialog>
    <AddDocumentModal
    :visible="showAddDocModal"
    :offer-id="offerId"
    @close="showAddDocModal = false"
    @document-added="fetchOfferDetails(offerId)"
    append-to-body

  />
  </div>
</template>


<script>
import AddDocumentModal from "./AddDocumentModal.vue";
export default {
  name: "EditOfferModal",
    components: {
    AddDocumentModal
  },
  props: {
    visible: { type: Boolean, required: true },
    offerId: { type: [Number, String], required: true }
  },
  data() {
    return {
      localVisible: this.visible,
      showAddDocModal: false,
      selectedOfferId: null,
      form: {
        objeto: "",
        descripcion: "",
        moneda: "",
        presupuesto: null,
        actividad_id: null,
        fecha_inicio: "",
        hora_inicio: "",
        fecha_cierre: "",
        hora_cierre: "",
        estado: ""
      },
      actividades: [],
      rules: {
        // ... (usa las mismas reglas que en CreateOfferModal)
        objeto: [{ required: true, message: "Requerido", trigger: "blur" }],
        descripcion: [{ required: true, message: "Requerido", trigger: "blur" }],
        moneda: [{ required: true, message: "Requerido", trigger: "change" }],
        presupuesto: [{ required: true, message: "Requerido", trigger: "blur" }],
        actividad_id: [{ required: true, message: "Requerido", trigger: "change" }],
        fecha_inicio: [{ required: true, message: "Requerido", trigger: "change" }],
        fecha_cierre: [{ required: true, message: "Requerido", trigger: "change" }],
        hora_inicio: [{ required: true, message: "Requerido", trigger: "change" }],
        hora_cierre: [{ required: true, message: "Requerido", trigger: "change" }]
      }
    };
  },
  watch: {
     // Watch combinado: se ejecuta al montar si hay offerId y visible es true,
    // y también cuando cualquiera de las dos props cambie.
    offerId: {
      handler(newId) {
        if (newId && this.visible) {
          this.fetchOfferDetails(newId);
          this.fetchActividades();
        }
      },
      immediate: true // ✅ clave: ejecutar al montar si offerId ya está definido
    },
    visible: {
      handler(val) {
        this.localVisible = val;
        if (val && this.offerId) {
          this.fetchOfferDetails(this.offerId);
          this.fetchActividades();
        }
      },
      immediate: true // también útil si el modal se abre sin cambiar offerId
    }
  },
  methods: {
    parseDateLocal(str) {
      if (!str) return null;
      const [y, m, d] = str.split('-').map(Number);
      return new Date(y, m - 1, d);
    },
    parseTimeLocal(str) {
      if (!str) return null;
      const [h, min] = str.split(':').map(Number);
      const d = new Date(2000, 0, 1);
      d.setHours(h, min, 0, 0);
      return d;
    },
    formatDateForBackend(date) {
      if (!date) return null;
      return new Date(date).toISOString().split('T')[0];
    },
    formatTimeForBackend(time) {
      if (!time) return null;
      return new Date(time).toTimeString().substring(0, 5);
    },
    async fetchActividades() {
      try {
        const res = await fetch(`${API_BASE_URL}/actividades`);
        if (res.ok) this.actividades = await res.json();
      } catch (err) {
        console.error(err);
      }
    },
    async handleActividadSearch(query) {
        this.searchTerm = query;

        // Limpiar resultados previos
        this.actividades = [];

        // Si el query tiene menos de 2 caracteres, no buscar
        if (!query || query.length < 2) {
          this.loadingActividades = false;
          return;
        }

        this.loadingActividades = true;
        try {
          // Asume que tu API acepta un parámetro `q` o `search`
          const response = await fetch(`${API_BASE_URL}/actividades/buscar/?query=${encodeURIComponent(query)}`);
          if (!response.ok) throw new Error("Error al buscar actividades");
          this.actividades = await response.json();
        } catch (err) {
          console.error("Error al buscar actividades:", err);
          this.$message.error("Error al cargar actividades");
          this.actividades = [];
        } finally {
          this.loadingActividades = false;
        }
    },
    async fetchOfferDetails(id) {
      try {
        const res = await fetch(`${API_BASE_URL}/ofertas/${id}`);
        if (!res.ok) throw new Error("Error al cargar la oferta");
        const data = await res.json();

        // Asignar valores del formulario
        this.form = {
          objeto: data.objeto || "",
          descripcion: data.descripcion || "",
          moneda: data.moneda || "",
          presupuesto: parseFloat(data.presupuesto) || null,
          actividad_id: data.actividad_id || null,
          fecha_inicio: this.parseDateLocal(data.fecha_inicio),
          fecha_cierre: this.parseDateLocal(data.fecha_cierre),
          hora_inicio: this.parseTimeLocal(data.hora_inicio),
          hora_cierre: this.parseTimeLocal(data.hora_cierre),
          estado: data.estado || ""
        };

        // ✅ Añadir la actividad anidada a la lista para que el select la muestre
        if (data.actividad) {
          // Verificar si ya está en la lista (evitar duplicados)
          const exists = this.actividades.some(a => a.id === data.actividad.id);
          if (!exists) {
            this.actividades = [data.actividad, ...this.actividades];
          }
        }
      } catch (err) {
        console.error("Error al cargar la oferta:", err);
        this.$message.error("Error al cargar los detalles de la oferta");
      }
    },
    async submitForm() {
      await this.$refs.formRef.validate(async (valid) => {
        if (!valid) return;

        const payload = {
          objeto: this.form.objeto,
          descripcion: this.form.descripcion,
          moneda: this.form.moneda,
          presupuesto: this.form.presupuesto,
          actividad_id: this.form.actividad_id,
          fecha_inicio: this.formatDateForBackend(this.form.fecha_inicio),
          hora_inicio: this.formatTimeForBackend(this.form.hora_inicio),
          fecha_cierre: this.formatDateForBackend(this.form.fecha_cierre),
          hora_cierre: this.formatTimeForBackend(this.form.hora_cierre),
          estado: this.form.estado
        };

        try {
          const res = await fetch(`${API_BASE_URL}/ofertas/${this.offerId}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
          });

          if (!res.ok) throw new Error("Debe existir al menos un documento cargado");

          this.$message.success("Oferta actualizada");
          this.$emit("saved");
          this.closeModal();
        } catch (err) {
          this.$message.error(err.message || "Error al guardar");
        }
      });
    },
    closeModal() {
      this.localVisible = false;
      this.$emit("update:visible", false);
      this.$emit("close");
    },
    openAddDocumentModal() {
      this.showAddDocModal = true;
    }
  }
};
const API_BASE_URL = process.env.VUE_APP_API_BASE_URL;
</script>


<style scoped>
.dialog-footer {
  text-align: right;
}

.el-form-item .el-input,
.el-form-item .el-select,
.el-form-item .el-date-picker,
.el-form-item .el-time-picker {
  width: 100%;
}

.document-button-container {
  width: 100%;
  display: flex !important;
  justify-content: center !important;
  margin: 20px 0 !important;
}
</style>