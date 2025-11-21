import { useParams, Link, Navigate } from "react-router";
import { lazy, Suspense } from "react";

// GPT Sample

// Get all available post slugs
const postModules = import.meta.glob("../posts/*.mdx");
const availableSlugs = Object.keys(postModules).map((path) =>
	path.replace("../posts/", "").replace(".mdx", ""),
);

export default function BlogPost() {
	const { slug } = useParams<{ slug: string }>();

	if (!slug || !availableSlugs.includes(slug)) {
		return <Navigate to="/blog" replace />;
	}

	const Post = lazy(() => import(`../posts/${slug}.mdx`));

	return (
		<div className="max-w-3xl mx-auto">
			<Link
				to="/blog"
				className="inline-flex items-center text-blue-600 hover:text-blue-700 mb-8"
			>
				← Back to all posts
			</Link>

			<Suspense
				fallback={
					<div className="flex items-center justify-center py-12">
						<div className="text-gray-500">Loading post...</div>
					</div>
				}
			>
				<article className="prose prose-lg max-w-none">
					<Post />
				</article>
			</Suspense>
		</div>
	);
}
