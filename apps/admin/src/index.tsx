import { type RouteObject } from "react-router";
import Dashboard from "@/components/dashboard";

export const adminRoutes: RouteObject[] = [
	{
		path: "/admin",
		element: <Dashboard />,
		children: [
			{
				index: true,
				element: (<div>Hello!</div>),
			},
		],
	},
];
