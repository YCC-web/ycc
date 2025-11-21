import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import dts from "vite-plugin-dts";
import path from "path";

// https://vite.dev/config/
export default defineConfig({
	plugins: [
		react({
			babel: {
				plugins: [["babel-plugin-react-compiler"]],
			},
		}),
		tailwindcss(),
		dts(),
	],
	build: {
		lib: {
			entry: path.resolve(__dirname, "src/index.ts"),
			name: "YCC UI",
			formats: ["es"],
			fileName: "index",
		},
		sourcemap: true,
		rollupOptions: {
			external: ["react", "react-dom", "react/jsx-runtime"],
		},
	},
	esbuild: {
		keepNames: true,
	},
	resolve: {
		alias: {
			"@": path.resolve(__dirname, "./src"),
		},
	},
});
