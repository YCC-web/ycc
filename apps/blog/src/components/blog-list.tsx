import { Link, useSearchParams, Navigate } from "react-router";

// GPT Sample

const postModules = import.meta.glob<{
	frontmatter: {
		title: string;
		date: string;
		author: string;
		description?: string;
		tags?: string[];
	};
}>("../posts/*.mdx", { eager: true });

// Extract and sort posts
const posts = Object.entries(postModules)
	.map(([path, module]) => {
		const slug = path.replace("../posts/", "").replace(".mdx", "");
		return {
			slug,
			...module.frontmatter,
		};
	})
	.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

const POSTS_PER_PAGE = 10;

export default function BlogList() {
	const [searchParams, setSearchParams] = useSearchParams();
	const currentPage = parseInt(searchParams.get("page") || "1", 10);
	const totalPages = Math.ceil(posts.length / POSTS_PER_PAGE);

	// Redirect invalid pages
	if (currentPage < 1 || currentPage > totalPages) {
		return <Navigate to="/blog/posts?page=1" replace />;
	}

	const startIndex = (currentPage - 1) * POSTS_PER_PAGE;
	const currentPosts = posts.slice(startIndex, startIndex + POSTS_PER_PAGE);

	const goToPage = (page: number) => {
		setSearchParams({ page: page.toString() });
	};

	return (
		<div className="space-y-8">
			<h1 className="text-4xl font-bold">Blog Posts</h1>

			<div className="space-y-8">
				{currentPosts.map((post) => (
					<article key={post.slug} className="border-b pb-8 last:border-0">
						<Link to={`/blog/posts/${post.slug}`} className="group">
							<h2 className="text-2xl font-bold group-hover:text-blue-600 transition-colors mb-2">
								{post.title}
							</h2>
						</Link>

						<div className="flex items-center gap-4 text-sm text-gray-600 mb-3">
							<time dateTime={post.date}>
								{new Date(post.date).toLocaleDateString("en-US", {
									year: "numeric",
									month: "long",
									day: "numeric",
								})}
							</time>
							<span>by {post.author}</span>
						</div>

						{post.description && (
							<p className="text-gray-700 mb-3">{post.description}</p>
						)}

						{post.tags && post.tags.length > 0 && (
							<div className="flex gap-2 flex-wrap">
								{post.tags.map((tag) => (
									<span
										key={tag}
										className="px-3 py-1 bg-gray-100 text-gray-700 text-sm rounded-full"
									>
										{tag}
									</span>
								))}
							</div>
						)}
					</article>
				))}
			</div>

			{totalPages > 1 && (
				<nav className="flex justify-center items-center gap-4 pt-8">
					{currentPage > 1 ? (
						<button
							onClick={() => goToPage(currentPage - 1)}
							className="px-4 py-2 border rounded-lg hover:bg-gray-50 transition-colors"
						>
							← Previous
						</button>
					) : (
						<span className="px-4 py-2 text-gray-400">← Previous</span>
					)}

					<span className="text-gray-600">
						Page {currentPage} of {totalPages}
					</span>

					{currentPage < totalPages ? (
						<button
							onClick={() => goToPage(currentPage + 1)}
							className="px-4 py-2 border rounded-lg hover:bg-gray-50 transition-colors"
						>
							Next →
						</button>
					) : (
						<span className="px-4 py-2 text-gray-400">Next →</span>
					)}
				</nav>
			)}
		</div>
	);
}
