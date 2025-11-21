import "@ycc/ui/index.css";
import "@ycc/blog/index.css";
import { Button } from "@ycc/ui";
import { createRoot } from "react-dom/client";
import { createHashRouter, Link, RouterProvider } from "react-router";
import { blogRoutes } from "@ycc/blog";
import { adminRoutes } from "@ycc/admin";
import { StrictMode } from "react";

const router = createHashRouter([
	{ path: "/", element: <HomePage /> },
	{ path: "/client", element: <Client /> },
	...adminRoutes,
	...blogRoutes,
]);

createRoot(document.getElementById("root")!).render(
	<StrictMode>
		<RouterProvider router={router} />,
	</StrictMode>,
);

function HomePage() {
	return (
		<div className="flex flex-col items-center p-7 rounded-2xl">
			<h1>This is the homepage</h1>
			<Link to="/client">
				<Button>Go to client</Button>
			</Link>
		</div>
	);
}

function Client() {
	return (
		<div className="flex flex-col items-center p-7 rounded-2xl">
			<h1>This is the client page</h1>
			<Link to="/">
				<Button>Go to homepage</Button>
			</Link>
		</div>
	);
}
