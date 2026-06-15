/**
 * ShortcutHelpModal Component
 * Beautiful modal showing all keyboard shortcuts organized by category
 */

'use client';

import React, { useState, useMemo } from 'react';
import { useShortcutStore } from '@/store/shortcutStore';
import { ShortcutBadge } from './ShortcutBadge';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Search, Keyboard, Command, MousePointer2 } from 'lucide-react';
import type { ShortcutScope, Shortcut } from '@/types/shortcuts';

const SCOPE_LABELS: Record<ShortcutScope, string> = {
  global: '🌐 Global',
  pos: '💳 POS Billing',
  sales: '📊 Sales',
  purchase: '📦 Purchase',
  products: '📦 Products',
  parties: '👥 Parties',
  reports: '📈 Reports',
  tables: '📋 Tables',
  forms: '📝 Forms',
};

interface ShortcutGroup {
  scope: ShortcutScope;
  label: string;
  shortcuts: Shortcut[];
}

export const ShortcutHelpModal: React.FC = () => {
  const { helpModalOpen, closeHelpModal, registeredShortcuts } = useShortcutStore();
  const [searchTerm, setSearchTerm] = useState('');
  const [activeScope, setActiveScope] = useState<ShortcutScope>('global');

  const groups = useMemo(() => {
    const groupMap = new Map<ShortcutScope, Shortcut[]>();

    const scopes: ShortcutScope[] = ['global', 'pos', 'sales', 'purchase', 'products', 'parties', 'reports', 'tables', 'forms'];
    scopes.forEach((scope) => {
      groupMap.set(scope, []);
    });

    Array.from(registeredShortcuts.values()).forEach((shortcut) => {
      const shortcutScopes = Array.isArray(shortcut.scope) ? shortcut.scope : [shortcut.scope];
      shortcutScopes.forEach((scope) => {
        if (groupMap.has(scope)) {
          groupMap.get(scope)!.push(shortcut);
        }
      });
    });

    const result: ShortcutGroup[] = scopes.map((scope) => ({
      scope,
      label: SCOPE_LABELS[scope],
      shortcuts: (groupMap.get(scope) || []).sort((a, b) =>
        a.name.localeCompare(b.name)
      ),
    }));

    return result;
  }, [registeredShortcuts]);

  const filteredGroups = useMemo(() => {
    if (!searchTerm.trim()) {
      return groups;
    }

    const term = searchTerm.toLowerCase();
    return groups.map((group) => ({
      ...group,
      shortcuts: group.shortcuts.filter(
        (shortcut) =>
          shortcut.name.toLowerCase().includes(term) ||
          shortcut.description.toLowerCase().includes(term)
      ),
    }));
  }, [groups, searchTerm]);

  const visibleGroups = groups;
  const contentGroups = filteredGroups;

  const activeScopeValue = React.useMemo(() => {
    if (contentGroups.some((group) => group.scope === activeScope)) {
      return activeScope;
    }

    if (contentGroups.length > 0) {
      return contentGroups[0].scope;
    }

    return visibleGroups[0]?.scope ?? 'global';
  }, [activeScope, contentGroups, visibleGroups]);

  return (
    <Dialog open={helpModalOpen} onOpenChange={closeHelpModal}>
      <DialogContent className="flex h-[85vh] max-w-2xl flex-col gap-0 overflow-hidden p-0 sm:h-[75vh]">
        <DialogHeader className="p-6 pb-0 space-y-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg border border-primary/20 bg-primary-soft shadow-inner">
              <Keyboard className="h-5 w-5 text-primary" />
            </div>
            <div className="flex-1">
              <DialogTitle className="text-xl font-bold tracking-tight">
                Keyboard Shortcuts
              </DialogTitle>
              <DialogDescription className="text-sm">
                Master these shortcuts to optimize your workflow
              </DialogDescription>
            </div>
          </div>

          <div className="relative">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground transition-colors group-focus-within:text-primary" />
            <Input
              placeholder="Search by action or key..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="h-11 pl-10"
              autoFocus
            />
          </div>
        </DialogHeader>

        <div className="flex-1 flex flex-col min-h-0 mt-6">
          <Tabs
            value={activeScopeValue}
            onValueChange={(value) => setActiveScope(value as ShortcutScope)}
            className="flex-1 flex flex-col min-h-0"
          >
            {/* ── Tab bar ── */}
            <div className="px-6 py-4">
              <TabsList className="flex w-full items-center justify-start gap-2 overflow-x-auto rounded-xl border border-emerald-500/25 px-0 py-1 no-scrollbar scroll-smooth">
                {visibleGroups.map((group) => (
                  <TabsTrigger
                    key={group.scope}
                    value={group.scope}
                    className="shrink-0 rounded-xl px-5 py-2.5 text-sm font-semibold transition-all duration-200 text-slate-400 hover:text-slate-100 data-[state=active]:bg-emerald-500 data-[state=active]:text-white data-[state=active]:shadow-[0_4px_20px_rgba(16,185,129,0.30)]"
                  >
                    {group.label}
                  </TabsTrigger>
                ))}
              </TabsList>
            </div>

            <div className="flex-1 min-h-0 relative">
              {contentGroups.map((group) => (
                <TabsContent
                  key={group.scope}
                  value={group.scope}
                  className="absolute inset-0 mt-0 hidden focus-visible:outline-none data-[state=active]:flex data-[state=active]:flex-col"
                >
                  <div className="flex-1 overflow-y-auto px-6 py-6 space-y-3 no-scrollbar">
                    {group.shortcuts.length > 0 ? (
                      group.shortcuts.map((shortcut) => (
                        <div
                          key={shortcut.id}
                          className="group flex items-center justify-between gap-4 rounded-lg border border-border  p-4 transition-all duration-200 hover:border-primary/25 hover:bg-primary-soft"
                        >
                          <div className="flex-1 min-w-0">
                            <h4 className="text-sm font-medium text-foreground transition-colors">
                              {shortcut.name}
                            </h4>
                            <p className="mt-1 line-clamp-1 text-xs text-muted-foreground">
                              {shortcut.description}
                            </p>
                          </div>
                          <div className="shrink-0">
                            <ShortcutBadge
                              keys={shortcut.keys}
                              variant="outline"
                              className="scale-110 shadow-sm"
                            />
                          </div>
                        </div>
                      ))
                    ) : (
                      <div className="flex h-full min-h-45 flex-col items-center justify-center rounded-2xl border border-border bg-secondary/30 p-8 text-center text-sm text-muted-foreground">
                        <p className="font-medium text-slate-100">No shortcuts available</p>
                        <p className="mt-2 text-xs text-slate-400">This category currently has no shortcuts.</p>
                      </div>
                    )}
                  </div>
                </TabsContent>
              ))}
            </div>
          </Tabs>
        </div>

        {/* Footer Tips */}
        <div className="flex items-center justify-between gap-4 border-t border-border bg-secondary/40 p-4 px-6">
          <div className="flex items-center gap-2 text-[10px] text-muted-foreground sm:text-xs">
            <span className="flex items-center gap-1">
              <MousePointer2 className="w-3 h-3" />
              Click to view
            </span>
            <span className="h-1 w-1 rounded-full bg-muted-foreground/50" />
            <span className="flex items-center gap-1">
              <Command className="w-3 h-3" />
              Power user mode
            </span>
          </div>
          <p className="text-[10px] italic text-muted-foreground sm:text-xs">
            Tip: Shortcuts are disabled in text fields
          </p>
        </div>
      </DialogContent>
    </Dialog>
  );
};

export default ShortcutHelpModal;