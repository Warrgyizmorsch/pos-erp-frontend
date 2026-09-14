# POS ERP Frontend

A modern, high-performance Point of Sale (POS) and ERP dashboard built with Next.js and React.

## 🚀 Technologies & Libraries Used

- **Framework & Core:**
  - `Next.js 16` - React framework (App Router)
  - `React 19` - UI library
  - `TypeScript` - Type-safe JavaScript
- **State Management & Data Fetching:**
  - `zustand` - Lightweight state management
  - `axios` - HTTP client
  - `socket.io-client` - Realtime WebSocket client
- **Styling & UI Components:**
  - `Tailwind CSS 4` - Utility-first CSS framework
  - `shadcn/ui` (via `@radix-ui/react-*`) - Accessible, customizable UI components
  - `framer-motion` - Fluid animations
  - `lucide-react` - Beautiful SVG icons
  - `tailwind-merge` & `clsx` - Utility class merging
- **Forms & Validation:**
  - `react-hook-form` - Form state management
  - `zod` - Schema validation
  - `@hookform/resolvers` - Form validation resolvers
- **Data Visualization & Tables:**
  - `recharts` - Charting library
  - `@tanstack/react-table` - Headless table utility
- **Utilities & PDF/Print Handling:**
  - `date-fns` - Date formatting
  - `react-to-print` - Print window handling (thermal/A4 receipts)
  - `jspdf` & `jspdf-autotable` - Client-side PDF generation
  - `html2canvas` - HTML to image conversion
  - `react-barcode` - Barcode generation
  - `xlsx` - Excel export/import
  - `sonner` - Toast notifications

## ⚙️ Step-by-Step Setup Guide

### 1. Prerequisites
- Node.js (v18+)

### 2. Installation
Clone the repository and install the dependencies:
```bash
npm install
```

### 3. Environment Variables
Create a `.env.local` file in the root directory to configure the backend API URL:
```env
NEXT_PUBLIC_API_URL=http://localhost:5500/api
NEXT_PUBLIC_SOCKET_URL=http://localhost:5500
```

### 4. Running the Development Server
```bash
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) with your browser to see the app.

### 5. Building for Production
To create an optimized production build:
```bash
npm run build
```

### 6. Starting Production Server
```bash
npm start
```
