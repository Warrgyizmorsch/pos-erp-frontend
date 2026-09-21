import { ERPLayout } from "@/components/layouts/ERPLayout";
import { ErrorBoundary } from "@/components/shared/ErrorBoundary";

export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <ErrorBoundary>
      <ERPLayout>{children}</ERPLayout>
    </ErrorBoundary>
  );
}
