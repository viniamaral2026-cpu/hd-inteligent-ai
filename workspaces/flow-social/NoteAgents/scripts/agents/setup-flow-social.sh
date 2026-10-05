#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================================="
echo " FLOW SOCIAL - ENGINEERING BOOTSTRAP"
echo "=============================================="

cd "$PROJECT_ROOT"

echo ""
echo "[1/8] Verificando ferramentas..."

command -v node >/dev/null 2>&1 || {
    echo "ERRO: Node.js não instalado."
    exit 1
}

command -v npm >/dev/null 2>&1 || {
    echo "ERRO: npm não instalado."
    exit 1
}

command -v php >/dev/null 2>&1 || {
    echo "AVISO: PHP não encontrado."
}

command -v composer >/dev/null 2>&1 || {
    echo "AVISO: Composer não encontrado."
}

echo "Node: $(node --version)"
echo "NPM:  $(npm --version)"

echo ""
echo "[2/8] Criando arquivos raiz..."

cat > package.json <<'JSON'
{
  "name": "flow-social",
  "private": true,
  "version": "0.1.0",
  "packageManager": "npm@11",
  "workspaces": [
    "apps/web",
    "packages/ui",
    "packages/types",
    "packages/config",
    "packages/eslint-config"
  ],
  "scripts": {
    "dev": "npm run dev -w apps/web",
    "build": "npm run build -w apps/web",
    "start": "npm run start -w apps/web",
    "lint": "npm run lint -w apps/web",
    "test": "npm run test -w apps/web",
    "test:e2e": "npm run test:e2e -w apps/web"
  }
}
JSON

echo ""
echo "[3/8] Inicializando Front-end Next.js..."

cd apps/web

if [ ! -f package.json ]; then
    cat > package.json <<'JSON'
{
  "name": "@flow-social/web",
  "private": true,
  "version": "0.1.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "jest",
    "test:e2e": "playwright test"
  },
  "dependencies": {
    "@tanstack/react-query": "^5.0.0",
    "next": "^15.0.0",
    "next-auth": "^5.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "zustand": "^5.0.0",
    "zod": "^3.0.0",
    "lucide-react": "^0.468.0",
    "clsx": "^2.1.1",
    "tailwind-merge": "^2.5.0"
  },
  "devDependencies": {
    "@playwright/test": "^1.49.0",
    "@testing-library/jest-dom": "^6.6.0",
    "@testing-library/react": "^16.1.0",
    "@types/node": "^22.0.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "jest": "^29.7.0",
    "jest-environment-jsdom": "^29.7.0",
    "typescript": "^5.7.0",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0"
  }
}
JSON
fi

echo "Instalando dependências do Front-end..."
npm install

cd "$PROJECT_ROOT"

echo ""
echo "[4/8] Inicializando Backend PHP..."

cd apps/api

if [ ! -f composer.json ]; then
    cat > composer.json <<'JSON'
{
  "name": "flow-social/api",
  "description": "Flow Social API",
  "type": "project",
  "require": {
    "php": "^8.4",
    "symfony/console": "^7.0",
    "symfony/http-foundation": "^7.0",
    "symfony/routing": "^7.0",
    "psr/log": "^3.0",
    "ramsey/uuid": "^4.7",
    "predis/predis": "^2.3"
  },
  "require-dev": {
    "pestphp/pest": "^3.0",
    "phpunit/phpunit": "^11.0",
    "phpstan/phpstan": "^2.0"
  },
  "autoload": {
    "psr-4": {
      "FlowSocial\\Domain\\": "src/Domain/",
      "FlowSocial\\Application\\": "src/Application/",
      "FlowSocial\\Infrastructure\\": "src/Infrastructure/",
      "FlowSocial\\Interfaces\\": "src/Interfaces/"
    }
  },
  "autoload-dev": {
    "psr-4": {
      "FlowSocial\\Tests\\": "tests/"
    }
  },
  "scripts": {
    "test": "vendor/bin/pest",
    "analyse": "vendor/bin/phpstan analyse"
  }
}
JSON
fi

if command -v composer >/dev/null 2>&1; then
    composer install
else
    echo "Composer não encontrado. Backend será instalado posteriormente."
fi

cd "$PROJECT_ROOT"

echo ""
echo "[5/8] Criando configuração TypeScript..."

if [ ! -f apps/web/tsconfig.json ]; then
cat > apps/web/tsconfig.json <<'JSON'
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"],
      "@flow/ui/*": ["../../packages/ui/src/*"],
      "@flow/types/*": ["../../packages/types/src/*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts"
  ],
  "exclude": ["node_modules"]
}
JSON
fi

echo ""
echo "[6/8] Criando arquivos básicos do Next.js..."

mkdir -p apps/web/src/app

cat > apps/web/src/app/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --flow-blue: #2563eb;
  --flow-cyan: #06b6d4;
  --flow-background: #ffffff;
  --flow-foreground: #0f172a;
}

* {
  box-sizing: border-box;
}

html,
body {
  margin: 0;
  padding: 0;
  min-height: 100%;
}

body {
  background: var(--flow-background);
  color: var(--flow-foreground);
}
CSS

cat > apps/web/src/app/layout.tsx <<'TSX'
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Flow Social",
  description: "Flow Social Platform",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="pt-BR">
      <body>{children}</body>
    </html>
  );
}
TSX

echo ""
echo "[7/8] Criando página inicial..."

cat > apps/web/src/app/page.tsx <<'TSX'
export default function HomePage() {
  return (
    <main className="min-h-screen bg-white">
      <section className="mx-auto flex min-h-screen max-w-7xl items-center justify-center px-6">
        <div className="text-center">
          <h1 className="text-5xl font-bold tracking-tight text-slate-900">
            FLOW SOCIAL
          </h1>

          <p className="mt-4 text-lg text-slate-600">
            Social Platform
          </p>

          <div className="mx-auto mt-8 h-1 w-24 rounded-full bg-cyan-500" />
        </div>
      </section>
    </main>
  );
}
TSX

echo ""
echo "[8/8] Criando configuração Tailwind..."

cat > apps/web/tailwind.config.ts <<'TS'
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};

export default config;
TS

cat > apps/web/postcss.config.mjs <<'JS'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
JS

cd "$PROJECT_ROOT"

echo ""
echo "=============================================="
echo " FLOW SOCIAL BOOTSTRAP FINALIZADO"
echo "=============================================="
echo ""
echo "Frontend:"
echo "  cd apps/web"
echo "  npm run dev"
echo ""
echo "URL:"
echo "  http://localhost:3000"
echo ""
echo "Backend:"
echo "  apps/api"
echo ""
echo "Arquitetura:"
echo "  apps/web       -> Next.js"
echo "  apps/api       -> PHP"
echo "  apps/worker    -> Workers"
echo "  packages/*     -> Pacotes compartilhados"
echo "  infrastructure -> Docker/Kubernetes"
echo "  docs           -> Engenharia"
echo ""
