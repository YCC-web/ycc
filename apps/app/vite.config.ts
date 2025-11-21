import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";
import dts from "vite-plugin-dts";

// https://vite.dev/config/
export default defineConfig({
	plugins: [
		react({
			babel: {
				plugins: [["babel-plugin-react-compiler"]],
			},
		}),
		dts(),
	],
	build: {
		lib: {
			entry: path.resolve(__dirname, "src/index.tsx"),
			name: "YCC App",
			formats: ["es"],
			fileName: "index",
		},
		sourcemap: true,
		rollupOptions: {
			external: ["react", "react-dom", "react/jsx-runtime", "react-router"],
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
	server: {
		port: 5176,
	},
	base: "/ycc/",
});
