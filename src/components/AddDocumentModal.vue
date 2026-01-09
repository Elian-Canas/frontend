<template>
  <el-dialog
    title="Agregar Documento"
    :visible="visible"
    width="60%"
    @close="closeModal"
    append-to-body
  >
    <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
      <!-- Título -->
      <el-form-item label="Título" prop="titulo">
        <el-input
          v-model="form.titulo"
          maxlength="100"
          show-word-limit
          placeholder="Titulo del documento"
        />
      </el-form-item>

      <!-- Descripción -->
      <el-form-item label="Descripción" prop="descripcion">
        <el-input
          v-model="form.descripcion"
          type="textarea"
          maxlength="200"
          show-word-limit
          placeholder="Breve descripción del documento"
        />
      </el-form-item>

      <!-- Archivo -->
      <el-form-item label="Archivo" prop="archivo">
        <el-upload
          ref="uploadRef"
          :auto-upload="false"
          :on-change="handleFileChange"
          :file-list="fileList"
          accept=".pdf,.zip"
          :limit="1"
          :on-exceed="handleExceed"
        >
          <el-button size="small" type="primary">Seleccionar archivo</el-button>
          <template #tip>
            <div class="el-upload__tip">
              Formatos permitidos: PDF, ZIP (máx. 1 archivo)
            </div>
          </template>
        </el-upload>
      </el-form-item>
    </el-form>

    <div slot="footer" class="dialog-footer">
      <el-button @click="closeModal">Cancelar</el-button>
      <el-button type="primary" :loading="loading" @click="submitForm">
        Subir Documento
      </el-button>
    </div>
  </el-dialog>
</template>

<script>
export default {
  name: "AddDocumentModal",
  props: {
    visible: { type: Boolean, required: true },
    offerId: { type: [Number, String], required: true } // ← Recibimos el ID de la oferta
  },
  data() {
    return {
      loading: false,
      form: {
        titulo: "",
        descripcion: ""
      },
      fileList: [],
      rules: {
        titulo: [
          { required: true, message: "El título es obligatorio", trigger: "blur" },
          { max: 100, message: "Máximo 100 caracteres", trigger: "blur" }
        ],
        descripcion: [
          { required: true, message: "La descripción es obligatoria", trigger: "blur" },
          { max: 200, message: "Máximo 200 caracteres", trigger: "blur" }
        ],
        archivo: [
          { required: true, validator: this.validateFile, trigger: "change" }
        ]
      }
    };
  },
  methods: {
    validateFile(rule, value, callback) {
      if (!this.fileList || this.fileList.length === 0) {
        callback(new Error("Por favor seleccione un archivo"));
      } else {
        callback();
      }
    },

    handleFileChange(file, fileList) {
      this.fileList = fileList.slice(-1); // Solo permite 1 archivo
    },

    handleExceed() {
      this.$message.warning("Solo puede subir un archivo a la vez");
    },

    async submitForm() {
      await this.$refs.formRef.validate(async (valid) => {
        if (!valid) return;

        const file = this.fileList[0]?.raw;
        if (!file) {
          this.$message.error("Archivo no válido");
          return;
        }

        this.loading = true;
        try {
          // ✅ Usamos FormData porque vamos a subir un archivo
          const formData = new FormData();
          formData.append("titulo", this.form.titulo);
          formData.append("descripcion", this.form.descripcion);
          formData.append("licitacion_id", this.offerId);
          formData.append("archivo", file);

          const response = await fetch(
            `${API_BASE_URL}/documentos`,
            {
              method: "POST",
              body: formData
            }
          );

          if (!response.ok) {
            const errorText = await response.text();
            throw new Error(errorText || "Error al subir el documento");
          }

          this.$message.success("Documento agregado exitosamente");
          this.$emit("document-added"); // Notifica al padre
          this.resetForm();
          this.closeModal();
        } catch (error) {
          console.error("Error al subir documento:", error);
          this.$message.error(error.message || "Error al guardar el documento");
        } finally {
          this.loading = false;
        }
      });
    },

    resetForm() {
      this.form = { titulo: "", descripcion: "" };
      this.fileList = [];
      this.$refs.formRef?.resetFields();
    },

    closeModal() {
      this.resetForm();
      this.$emit("close");
    }
  }
};
const API_BASE_URL = process.env.VUE_APP_API_BASE_URL;
</script>

<style scoped>
.dialog-footer {
  text-align: right;
}
</style>