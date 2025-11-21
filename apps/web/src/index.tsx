import { Button } from '@ycc/ui';
import { createRoot } from 'react-dom/client';
import { createHashRouter, Link, RouterProvider } from 'react-router';
import '@ycc/ui/index.css';

const router = createHashRouter([
  { path: '/', element: <HomePage /> },
  { path: '/client', element: <Client /> },
]);

createRoot(document.getElementById('root')!).render(
  <RouterProvider router={router} />
);

function HomePage() {
  return (
    <div className="flex flex-col items-center p-7 rounded-2xl">
      <h1>This is the homepage</h1>
      <Link to="/client"><Button>Go to client</Button></Link>
    </div>
    
  )
}

function Client() {
  return (
    <div className="flex flex-col items-center p-7 rounded-2xl">
      <h1>This is the client page</h1>
      <Link to="/"><Button>Go to homepage</Button></Link>
    </div>
  )
}