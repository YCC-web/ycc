import { createRoot } from 'react-dom/client';
import { createHashRouter, RouterProvider } from 'react-router'; // v7 import!

const router = createHashRouter([
  { path: '/', element: <HomePage /> },
  { path: '/app', element: <Client /> },
]);



createRoot(document.getElementById('root')!).render(
  <RouterProvider router={router} />
);

function HomePage() {
  return (
    <div className="flex flex-col items-center p-7 rounded-2xl">HELLO WORLD</div>
  )
}

function Client() {
  return (
    <div>CLIENT</div>
  )
}