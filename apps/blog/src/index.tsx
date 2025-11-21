import { Navigate, type RouteObject } from "react-router";
import Layout from "@/components/layout";
import BlogList from "@/components/blog-list";
import BlogPost from "@/components/blog-post";
import 'highlight.js/styles/github-dark.css';

export const blogRoutes: RouteObject[] = [
	{
		path: "/blog",
		element: <Layout />,
		children: [
			{
				index: true,
				element: <Navigate to="/blog/page/1" replace />,
			},
			{
				path: "page/:page",
				element: <BlogList />,
			},
			{
				path: ":slug",
				element: <BlogPost />,
			},
		],
	},
];
