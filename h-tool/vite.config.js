import { defineConfig } from "vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [],
  build: {
    lib: {
      entry: "tool/index.js", // 工具库入口
      name: "hTool", // 工具库名称
      fileName: (format) => `hTool.${format}.js`, // 工具库名称
    },
  },
});
