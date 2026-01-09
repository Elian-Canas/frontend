<template>
  <el-dialog title="Crear Oferta" :visible="visible" width="50%" @close="closeModal">
    <el-form :model="form" :rules="rules" ref="formRef">
      <el-form-item label="Objeto" :label-width="formLabelWidth" prop="objeto">
        <el-input v-model="form.objeto" maxlength="150" show-word-limit autocomplete="off"/>
      </el-form-item>
      <el-form-item label="Descripción" :label-width="formLabelWidth" prop="descripcion">
        <el-input v-model="form.descripcion" type="textarea" maxlength="400" show-word-limit autocomplete="off"/>
      </el-form-item>
      <el-form-item label="Moneda" :label-width="formLabelWidth" prop="moneda">
        <el-select v-model="form.moneda" placeholder="Seleccione">
          <el-option label="COP" value="COP" />
          <el-option label="USD" value="USD" />
          <el-option label="EUR" value="EUR" />
        </el-select>
      </el-form-item>
      <el-form-item label="Presupuesto" :label-width="formLabelWidth" prop="presupuesto">
        <el-input v-model="form.presupuesto" type="number" min="0" step="0.01" autocomplete="off"/>
      </el-form-item>
      <el-form-item label="Actividad" :label-width="formLabelWidth" prop="actividad_id">
        <el-select
          v-model="form.actividad_id"
          placeholder="Escriba para buscar"
          filterable
          remote
          :remote-method="handleActividadSearch"
          :loading="loadingActividades"
          :no-match-text="searchTerm && searchTerm.length < 2 ? 'Escriba al menos 2 caracteres' : 'No hay resultados'"
          :no-data-text="!searchTerm ? 'Escriba para buscar' : 'No hay datos'"
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

      <el-form-item label="Fecha Inicio" :label-width="formLabelWidth" prop="fecha_inicio">
        <el-date-picker v-model="form.fecha_inicio" type="date" placeholder="Seleccione fecha"/>
      </el-form-item>
      <el-form-item label="Hora Inicio" :label-width="formLabelWidth" prop="hora_inicio">
        <el-time-picker
          v-model="form.hora_inicio"
          placeholder="Seleccione hora"
          value-format="HH:mm"
        />
      </el-form-item>
      <el-form-item label="Fecha Cierre" :label-width="formLabelWidth" prop="fecha_cierre">
        <el-date-picker v-model="form.fecha_cierre" type="date" placeholder="Seleccione fecha"/>
      </el-form-item>
      <el-form-item label="Hora Cierre" :label-width="formLabelWidth" prop="hora_cierre">
        <el-time-picker
          v-model="form.hora_cierre"
          placeholder="Seleccione hora"
          value-format="HH:mm"
        />
      </el-form-item>
    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button @click="closeModal">Cancelar</el-button>
      <el-button type="primary" @click="submitForm">Crear</el-button>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: "CreateOfferModal",
  props: {
    visible: {
      type: Boolean,
      required: true,
    },
    offer: {
      type: Object,
      default: null,
    },
  },
  data() {
    return {
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
      },
      formLabelWidth: "120px",
      actividades: [],
      loadingActividades: false,
      searchTerm: '', 
      rules: {
        objeto: [
          { required: true, message: "El objeto es obligatorio", trigger: "blur" },
          { max: 150, message: "Máximo 150 caracteres", trigger: "blur" },
        ],
        descripcion: [
          { required: true, message: "La descripción es obligatoria", trigger: "blur" },
          { max: 400, message: "Máximo 400 caracteres", trigger: "blur" },
        ],
        moneda: [
          { required: true, message: "La moneda es obligatoria", trigger: "change" },
        ],
        presupuesto: [
          { required: true, message: "El presupuesto es obligatorio", trigger: "blur" },
          {
            validator: (rule, value, callback) => {
              if (isNaN(value) || value <= 0) {
                callback(new Error("Debe ser un número mayor a 0"));
              } else {
                callback();
              }
            },
            trigger: "blur",
          },
        ],
        actividad_id: [
          { required: true, message: "La actividad es obligatoria", trigger: "change" },
        ],
        fecha_inicio: [
          { required: true, message: "La fecha de inicio es obligatoria", trigger: "change" },
          {
            validator: (rule, value, callback) => {
              if (!value) {
                callback();
                return;
              }

              const selectedDate = new Date(value);
              const today = new Date();

              // Normalizar ambas fechas a 00:00:00
              const selectedDay = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate());
              const todayDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());

              if (selectedDay < todayDay) {
                callback(new Error("La fecha de inicio no puede ser anterior a hoy"));
              } else {
                callback();
              }
            },
            trigger: "change",
          },
        ],
        hora_inicio: [
          { required: true, message: "La hora de inicio es obligatoria", trigger: "change" },
        ],
        fecha_cierre: [
          { required: true, message: "La fecha de cierre es obligatoria", trigger: "change" },
          {
            validator: (rule, value, callback) => {
              if (value && new Date(value) <= new Date(this.form.fecha_inicio)) {
                callback(new Error("La fecha de cierre debe ser mayor a la fecha de inicio"));
              } else {
                callback();
              }
            },
            trigger: "change",
          },
        ],
        hora_cierre: [
          { required: true, message: "La hora de cierre es obligatoria", trigger: "change" },
          {
            validator: (rule, value, callback) => {
              const fechaInicio = new Date(this.form.fecha_inicio);
              const fechaCierre = new Date(this.form.fecha_cierre);
              if (
                fechaInicio.toDateString() === fechaCierre.toDateString() &&
                value <= this.form.hora_inicio
              ) {
                callback(new Error("La hora de cierre debe ser mayor a la hora de inicio"));
              } else {
                callback();
              }
            },
            trigger: "change",
          },
        ],
      }
    };
  },
  methods: {
    closeModal() {
      this.$emit("close");
      this.$emit("update:mode", "create"); // Notify parent to reset mode
    },
    formatDate(date) {
      if (!date) return ''; // Si no hay fecha, devuelve cadena vacía

      const d = new Date(date); // Asegura que sea un objeto Date
      const year = d.getFullYear();
      const month = String(d.getMonth() + 1).padStart(2, '0'); // Mes va de 0 a 11
      const day = String(d.getDate()).padStart(2, '0');

      return `${year}-${month}-${day}`; // Ej: "2026-01-15"
    },
    formatTime(value) {
      if (!value || typeof value !== 'string') return '';
      
      const match = value.match(/T(\d{2}):(\d{2}):(\d{2})/);
      if (match) {
        return `${match[1]}:${match[2]}:${match[3]}`;
      }
      
      if (/^\d{2}:\d{2}$/.test(value)) {
        return `${value}:00`;
      }
      
      if (/^\d{2}:\d{2}:\d{2}$/.test(value)) {
        return value;
      }
      
      return '';
    },
    async submitForm() {
      this.$refs.formRef.validate(async (valid) => {
        if (valid) {
          try {
            const payload = {
              objeto: this.form.objeto,
              descripcion: this.form.descripcion,
              moneda: this.form.moneda,
              presupuesto: this.form.presupuesto,
              actividad_id: this.form.actividad_id,
              // ✅ Formateamos fechas y horas al formato esperado por la API
              fecha_inicio: this.formatDate(this.form.fecha_inicio),
              hora_inicio: this.formatTime(this.form.hora_inicio),
              fecha_cierre: this.formatDate(this.form.fecha_cierre),
              hora_cierre: this.formatTime(this.form.hora_cierre),
            };

            // Optional: log para verificar
            console.log("Payload a enviar:", payload);

            const response = await fetch(`${API_BASE_URL}/ofertas`, {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
              },
              body: JSON.stringify(payload),
            });

            if (!response.ok) {
              throw new Error("Error al crear la oferta");
            }

            const responseData = await response.json();
            console.log("Oferta creada exitosamente:", responseData);
            this.$message.success("Oferta creada exitosamente");
            this.$emit('created');
            this.closeModal();
          } catch (error) {
            console.error("Error al crear la oferta:", error);
            this.$message.error("Error al crear la oferta");
          }
        } else {
          console.log("Validation failed");
        }
      });
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
      console.log("llega aquii fetchhh");
      try {
        const response = await fetch(`${API_BASE_URL}/ofertas/${id}`);
        if (!response.ok) {
          throw new Error("Error al obtener los detalles de la oferta");
        }
        const offerDetails = await response.json();
      
        // Map fetched data to form
        this.form = {
          objeto: offerDetails.objeto || "",
          descripcion: offerDetails.descripcion || "",
          moneda: offerDetails.moneda || "",
          presupuesto: offerDetails.presupuesto || null,
          actividad_id: offerDetails.actividad_id || null,
          fecha_inicio: offerDetails.fecha_inicio ? new Date(offerDetails.fecha_inicio) : "",
          hora_inicio: offerDetails.hora_inicio || "",
          fecha_cierre: offerDetails.fecha_cierre ? new Date(offerDetails.fecha_cierre) : "",
          hora_cierre: offerDetails.hora_cierre || "",
          consecutivo: offerDetails.consecutivo || "",
          estado: offerDetails.estado || "",
        };
      } catch (error) {
        console.error("Error al obtener los detalles de la oferta:", error);
        this.$message.error("Error al obtener los detalles de la oferta");
      }
    },
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
</style>