import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import mdx from "@mdx-js/rollup";
import remarkFrontmatter from "remark-frontmatter";
import remarkMdxFrontmatter from "remark-mdx-frontmatter";
import remarkGfm from "remark-gfm";
import rehypeHighlight from "rehype-highlight";
import rehypeSlug from "rehype-slug";
import path from "path";
import dts from "vite-plugin-dts";
import rehypeAutolinkHeadings from "rehype-autolink-headings";

// https://vite.dev/config/
export default defineConfig({
	plugins: [
		{
			enforce: "pre",
			...mdx({
				remarkPlugins: [remarkFrontmatter, remarkMdxFrontmatter, remarkGfm],
				rehypePlugins: [rehypeHighlight, rehypeSlug, rehypeAutolinkHeadings],
			}),
		},
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
			name: "YCC Blog",
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
		port: 5174,
	},
	base: "/ycc/",
});
