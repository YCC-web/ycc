import { Outlet } from "react-router";

export default function Dashboard() {
	return (
		<div className="min-h-screen bg-white">
			<header className="border-b">
				<div className="max-w-4xl mx-auto px-4 py-6">
					<h1 className="text-2xl font-bold">This is a dashboard...</h1>
				</div>
			</header>

			<main className="max-w-4xl mx-auto px-4 py-12">
				<Outlet />
			</main>

			<footer className="border-t mt-16">
				<div className="max-w-4xl mx-auto px-4 py-6 text-center text-gray-600 text-sm">
					Dashboard footer
				</div>
			</footer>
		</div>
	);
}
