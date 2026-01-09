<template>
  <el-dialog title="Ver Oferta" :visible="visible" width="50%" @close="closeModal">
    <el-form :model="form" :rules="rules" ref="formRef">
      <el-form-item label="Objeto" :label-width="formLabelWidth" prop="objeto">
        <el-input v-model="form.objeto" maxlength="150" show-word-limit autocomplete="off" disabled/>
      </el-form-item>
      <el-form-item label="Descripción" :label-width="formLabelWidth" prop="descripcion">
        <el-input v-model="form.descripcion" type="textarea" maxlength="400" show-word-limit autocomplete="off" disabled/>
      </el-form-item>
      <el-form-item label="Moneda" :label-width="formLabelWidth" prop="moneda">
        <el-select v-model="form.moneda" placeholder="Seleccione" disabled>
          <el-option label="COP" value="COP" />
          <el-option label="USD" value="USD" />
          <el-option label="EUR" value="EUR" />
        </el-select>
      </el-form-item>
      <el-form-item label="Presupuesto" :label-width="formLabelWidth" prop="presupuesto">
        <el-input v-model="form.presupuesto" type="number" min="0" step="0.01" autocomplete="off" disabled/>
      </el-form-item>
      <el-form-item label="Actividad" :label-width="formLabelWidth" prop="actividad_id">
        <el-select v-model="form.actividad_id" placeholder="Seleccione" disabled>
          <el-option v-for="actividad in actividades" :key="actividad.id" :label="actividad.producto" :value="actividad.id"/>
        </el-select>
      </el-form-item>

      <h3 style="margin-top: 20px;">Cronograma</h3>

      <el-form-item label="Fecha Inicio" :label-width="formLabelWidth" prop="fecha_inicio">
        <el-date-picker v-model="form.fecha_inicio" type="date" placeholder="Seleccione fecha" disabled/>
      </el-form-item>
      <el-form-item label="Hora Inicio" :label-width="formLabelWidth" prop="hora_inicio">
        <el-time-picker v-model="form.hora_inicio" placeholder="Seleccione hora" disabled/>
      </el-form-item>
      <el-form-item label="Fecha Cierre" :label-width="formLabelWidth" prop="fecha_cierre">
        <el-date-picker v-model="form.fecha_cierre" type="date" placeholder="Seleccione fecha" disabled/>
      </el-form-item>
      <el-form-item label="Hora Cierre" :label-width="formLabelWidth" prop="hora_cierre">
        <el-time-picker v-model="form.hora_cierre" placeholder="Seleccione hora" disabled/>
      </el-form-item>
      <el-form-item label="Consecutivo" :label-width="formLabelWidth">
        <el-input v-model="form.consecutivo" disabled />
      </el-form-item>
      <el-form-item label="Estado" :label-width="formLabelWidth">
        <el-input v-model="form.estado" disabled />
      </el-form-item>
    </el-form>
    <div slot="footer" class="dialog-footer">
      <el-button @click="closeModal">Cerrar</el-button>
      <el-button type="primary" @click="editOffer">Editar</el-button>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: "ViewOfferModal",
  props: {
    visible: {
      type: Boolean,
      required: true,
    },
    mode: {
      type: String,
      default: "view",
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
      isEditOfferModalVisible: false,
      selectedOfferId: null,
      actividades: [],
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
              if (value && new Date(value) < new Date()) {
                callback(new Error("La fecha de inicio debe ser válida"));
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
  watch: {
    offer: {
      immediate: true,
      handler(newOffer) {
        if (this.mode === "view" && newOffer) {
          this.form = {
            ...newOffer,
            fecha_inicio: newOffer.fecha_inicio || "",
            hora_inicio: newOffer.hora_inicio || "",
            fecha_cierre: newOffer.fecha_cierre || "",
            hora_cierre: newOffer.hora_cierre || "",
          };
        }
      },
    },
  },
  methods: {
    closeModal() {
      this.$emit("close");
      this.$emit("update:mode", "create"); // Notify parent to reset mode
    },
    parseDateLocal(dateString) {
      if (!dateString) return null;
      const [year, month, day] = dateString.split('-').map(Number);
      return new Date(year, month - 1, day); // mes es 0-indexado
    },
    editOffer() {
      if (!this.offer?.id) {
        console.error("No se puede editar: oferta sin ID");
        return;
      }
      this.$emit("edit", this.offer.id); // ✅ ahora sí tienes el ID
      this.closeModal();
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
              fecha_inicio: this.form.fecha_inicio,
              hora_inicio: this.form.hora_inicio,
              fecha_cierre: this.form.fecha_cierre,
              hora_cierre: this.form.hora_cierre,
            };

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
    async fetchActividades() {
      try {
        const res = await fetch(`${API_BASE_URL}/actividades`);
        if (!res.ok) throw new Error("Error al obtener actividades");
        this.actividades = await res.json();
      } catch (err) {
        console.error("Error al obtener actividades:", err);
      }
    },
    async fetchOfferDetails(id) {
      try {
        const response = await fetch(`${API_BASE_URL}/ofertas/${id}`);
        if (!response.ok) {
          throw new Error("Error al obtener los detalles de la oferta");
        }
        const offerDetails = await response.json();

        // Convierte "HH:mm:ss" o "HH:mm" a Date (requerido por Element UI)
        const timeStringToDate = (timeStr) => {
          if (!timeStr) return null;
          const [hours, minutes] = timeStr.split(':').map(Number);
          const date = new Date(2000, 0, 1); // fecha fija, solo para la hora
          date.setHours(hours, minutes, 0, 0);
          return date;
        };

        this.form = {
          objeto: offerDetails.objeto || "",
          descripcion: offerDetails.descripcion || "",
          moneda: offerDetails.moneda || "",
          presupuesto: offerDetails.presupuesto ? parseFloat(offerDetails.presupuesto) : null,
          actividad_id: offerDetails.actividad_id || null,
          fecha_inicio: this.parseDateLocal(offerDetails.fecha_inicio),
          fecha_cierre: this.parseDateLocal(offerDetails.fecha_cierre),
          hora_inicio: timeStringToDate(offerDetails.hora_inicio),
          hora_cierre: timeStringToDate(offerDetails.hora_cierre),
          consecutivo: offerDetails.consecutivo || "",
          estado: offerDetails.estado || "",
        };
      } catch (error) {
        console.error("Error al obtener los detalles de la oferta:", error);
        this.$message.error("Error al obtener los detalles de la oferta");
      }
    }
  },
  mounted() {
    this.fetchActividades();
  },
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