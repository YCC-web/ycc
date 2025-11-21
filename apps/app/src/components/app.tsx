import { Outlet } from "react-router";

export default function App() {
	return (
		<div className="min-h-screen bg-white">
			<header className="border-b">
				<div className="max-w-4xl mx-auto px-4 py-6">
					<h1 className="text-2xl font-bold">This is the app...</h1>
				</div>
			</header>

			<main className="max-w-4xl mx-auto px-4 py-12">
				<Outlet />
			</main>

			<footer className="border-t mt-16">
				<div className="max-w-4xl mx-auto px-4 py-6 text-center text-gray-600 text-sm">
					App footer
				</div>
			</footer>
		</div>
	);
}
