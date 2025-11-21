import { type RouteObject } from "react-router";
import App from "@/components/app";

export const appRoutes: RouteObject[] = [
	{
		path: "/app",
		element: <App />,
		children: [
			{
				index: true,
				element: (<div>Hello!</div>),
			},
		],
	},
];
