"use client";

import { useEffect, useState } from "react";
import { Loader2, Users, ShieldAlert, Key, Settings2, Plus, Edit, Trash2, Eye, EyeOff } from "lucide-react";
import { toast } from "sonner";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Checkbox } from "@/components/ui/checkbox";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { authService } from "@/services/authService";
import { useAuthStore } from "@/store/authStore";
import type { User, Role } from "@/types";

const ALL_MODULES = [
  'dashboard', 'sales', 'purchases', 'inventory', 'products', 'categories', 
  'subcategories', 'customers', 'suppliers', 'accounting', 'bank', 'cash', 
  'cash-bank', 'expenses', 'loans', 'cheques', 'reports', 'settings', 'pos', 
  'activity', 'shifts', 'backup', 'transporters', 'utilities', 'checkout'
];

const formatModuleName = (m: string) => m.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');

export function UserManagement() {
  const { user: currentUser } = useAuthStore();
  const [users, setUsers] = useState<User[]>([]);
  const [roles, setRoles] = useState<Role[]>([]);
  const [loading, setLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  // Dialog state for Role Permissions
  const [selectedRole, setSelectedRole] = useState<Role | null>(null);
  const [rolePermissions, setRolePermissions] = useState<string[]>([]);
  const [isRoleDialogOpen, setIsRoleDialogOpen] = useState(false);

  // Unified Dialog for Create / Edit User
  const [isUserDialogOpen, setIsUserDialogOpen] = useState(false);
  const [isEditingUser, setIsEditingUser] = useState(false);
  const [userForm, setUserForm] = useState<Partial<User> & { password?: string }>({});
  const [userPermissions, setUserPermissions] = useState<string[]>([]);
  const [showPassword, setShowPassword] = useState(false);

  // Dialog state for Deleting User
  const [userToDelete, setUserToDelete] = useState<User | null>(null);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [usersRes, rolesRes] = await Promise.all([
        authService.getUsers(),
        authService.getRoles()
      ]);
      
      if (usersRes.success) setUsers(usersRes.data);
      if (rolesRes.success) setRoles(rolesRes.data);
    } catch {
      toast.error("Failed to load users and roles");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void fetchData();
  }, []);

  // --- Role Permissions Handlers ---
  const openRoleDialog = (role: Role) => {
    setSelectedRole(role);
    setRolePermissions(role.permissions || []);
    setIsRoleDialogOpen(true);
  };

  const toggleRolePermission = (module: string) => {
    setRolePermissions(prev => 
      prev.includes(module) ? prev.filter(p => p !== module) : [...prev, module]
    );
  };

  const saveRolePermissions = async () => {
    if (!selectedRole) return;
    try {
      setUpdatingId(`role-${selectedRole._id}`);
      const res = await authService.updateRolePermissions(selectedRole._id, rolePermissions);
      if (res.success) {
        setRoles(prev => prev.map(r => r._id === selectedRole._id ? { ...r, permissions: rolePermissions } : r));
        toast.success(`${selectedRole.name} permissions updated`);
        setIsRoleDialogOpen(false);
      }
    } catch (err: any) {
      toast.error(err?.response?.data?.message || "Failed to update role permissions");
    } finally {
      setUpdatingId(null);
    }
  };

  // --- Unified User Handlers ---
  const handleOpenAddUser = () => {
    setUserForm({ role: 'cashier', isActive: true });
    setUserPermissions([]);
    setIsEditingUser(false);
    setShowPassword(false);
    setIsUserDialogOpen(true);
  };

  const handleOpenEditUser = (user: User) => {
    setUserForm({ ...user, password: "" }); // Reset password field
    setShowPassword(false);
    if (user.permissions && user.permissions.length > 0) {
      setUserPermissions(user.permissions);
    } else {
      // Fallback to role's default permissions
      const defaultRole = roles.find(r => r.name === user.role);
      setUserPermissions(defaultRole?.permissions || []);
    }
    setIsEditingUser(true);
    setIsUserDialogOpen(true);
  };

  const toggleUserPermission = (module: string) => {
    setUserPermissions(prev => 
      prev.includes(module) ? prev.filter(p => p !== module) : [...prev, module]
    );
  };

  const saveUser = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setUpdatingId("user-save");
      const payload = { ...userForm, permissions: userPermissions };

      if (isEditingUser && userForm._id) {
        // Edit User
        const res = await authService.updateUser(userForm._id, payload);
        if (res.success) {
          setUsers(prev => prev.map(u => u._id === userForm._id ? res.data : u));
          toast.success("User updated successfully");
          setIsUserDialogOpen(false);
        }
      } else {
        // Create User
        if (!userForm.password) {
          toast.error("Password is required for a new user");
          return;
        }
        const res = await authService.createUser(payload);
        if (res.success) {
          setUsers(prev => [...prev, res.data]);
          toast.success("User created successfully");
          setIsUserDialogOpen(false);
        }
      }
    } catch (err: any) {
      toast.error(err?.response?.data?.message || "Failed to save user");
    } finally {
      setUpdatingId(null);
    }
  };

  const handleDeleteUser = async () => {
    if (!userToDelete) return;
    try {
      setUpdatingId(`user-del-${userToDelete._id}`);
      const res = await authService.deleteUser(userToDelete._id);
      if (res.success) {
        setUsers(prev => prev.filter(u => u._id !== userToDelete._id));
        toast.success("User deleted successfully");
        setIsDeleteDialogOpen(false);
      }
    } catch (err: any) {
      toast.error(err?.response?.data?.message || "Failed to delete user");
    } finally {
      setUpdatingId(null);
    }
  };

  if (loading) {
    return (
      <Card>
        <CardContent className="h-48 flex items-center justify-center">
          <Loader2 className="h-6 w-6 animate-spin text-primary" />
        </CardContent>
      </Card>
    );
  }

  return (
    <>
      <Tabs defaultValue="users" className="space-y-4">
        <TabsList>
          <TabsTrigger value="users" className="gap-2"><Users className="h-4 w-4" /> Users</TabsTrigger>
          <TabsTrigger value="roles" className="gap-2"><Key className="h-4 w-4" /> Roles & Defaults</TabsTrigger>
        </TabsList>

        <TabsContent value="users">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-4">
              <div>
                <CardTitle>User Management</CardTitle>
                <CardDescription className="mt-1.5">
                  Manage users, roles, and fine-grained permissions.
                </CardDescription>
              </div>
              <Button onClick={handleOpenAddUser} className="gap-2">
                <Plus className="h-4 w-4" />
                Add User
              </Button>
            </CardHeader>
            <CardContent>
              <div className="divide-y divide-border border rounded-xl overflow-hidden bg-card">
                {users.map((u) => (
                  <div key={u._id} className="flex flex-col sm:flex-row sm:items-center justify-between p-4 gap-4">
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="h-10 w-10 rounded-full bg-primary/10 text-primary border border-primary/20 flex items-center justify-center text-sm font-semibold shrink-0 aspect-square">
                        {u.name?.charAt(0).toUpperCase()}
                      </div>
                      <div className="min-w-0">
                        <div className="flex items-center gap-2">
                          <p className="font-medium text-sm truncate">{u.name}</p>
                          {!u.isActive && <Badge variant="destructive" className="text-[10px] h-4">Inactive</Badge>}
                        </div>
                        <p className="text-xs text-muted-foreground truncate">{u.email} • {u.phone || 'No Phone'}</p>
                      </div>
                    </div>

                    <div className="flex items-center gap-3 shrink-0 sm:ml-auto">
                      {u._id === currentUser?._id ? (
                        <Badge variant="secondary" className="capitalize select-none flex items-center gap-1.5 h-8">
                          <ShieldAlert className="h-3 w-3" />
                          Admin (You)
                        </Badge>
                      ) : (
                        <Badge variant="outline" className="capitalize select-none h-8 bg-muted/50">
                          {u.role.replace('_', ' ')}
                        </Badge>
                      )}
                      
                      <div className="flex items-center gap-2 ml-2">
                        <Button 
                          variant="outline" 
                          size="icon" 
                          className="h-8 w-8"
                          onClick={() => handleOpenEditUser(u)}
                        >
                          <Edit className="h-4 w-4 text-muted-foreground" />
                        </Button>
                        <Button 
                          variant="outline" 
                          size="icon" 
                          className="h-8 w-8 hover:bg-destructive/10 hover:text-destructive hover:border-destructive/30"
                          disabled={u._id === currentUser?._id}
                          onClick={() => {
                            setUserToDelete(u);
                            setIsDeleteDialogOpen(true);
                          }}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="roles">
          <Card>
            <CardHeader>
              <CardTitle>Role Defaults</CardTitle>
              <CardDescription>
                Define the default module permissions granted when a user is assigned a specific role.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {roles.map(role => (
                  <Card key={role._id} className="overflow-hidden">
                    <CardHeader className="bg-muted/50 py-3">
                      <CardTitle className="text-base capitalize flex items-center justify-between">
                        {role.name.replace('_', ' ')}
                        <Button 
                          variant="ghost" 
                          size="sm" 
                          className="h-7 px-2"
                          onClick={() => openRoleDialog(role)}
                        >
                          Edit
                        </Button>
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="p-4">
                      <div className="flex flex-wrap gap-1.5">
                        {role.permissions.slice(0, 8).map(p => (
                          <Badge key={p} variant="secondary" className="text-[10px] font-normal">{formatModuleName(p)}</Badge>
                        ))}
                        {role.permissions.length > 8 && (
                          <Badge variant="outline" className="text-[10px]">+{role.permissions.length - 8} more</Badge>
                        )}
                        {role.permissions.length === 0 && (
                          <span className="text-xs text-muted-foreground italic">No default permissions</span>
                        )}
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Role Permissions Dialog */}
      <Dialog open={isRoleDialogOpen} onOpenChange={setIsRoleDialogOpen}>
        <DialogContent className="max-w-2xl max-h-[85vh] overflow-hidden flex flex-col">
          <DialogHeader>
            <DialogTitle className="capitalize">{selectedRole?.name.replace('_', ' ')} - Default Permissions</DialogTitle>
            <DialogDescription>
              Select the modules that users with this role will have access to by default.
            </DialogDescription>
          </DialogHeader>
          <div className="flex-1 overflow-y-auto py-4">
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
              {ALL_MODULES.map(module => (
                <div key={module} className="flex items-center space-x-2">
                  <Checkbox 
                    id={`role-mod-${module}`} 
                    checked={rolePermissions.includes(module)}
                    onCheckedChange={() => toggleRolePermission(module)}
                  />
                  <label 
                    htmlFor={`role-mod-${module}`}
                    className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 cursor-pointer"
                  >
                    {formatModuleName(module)}
                  </label>
                </div>
              ))}
            </div>
          </div>
          <DialogFooter className="mt-4">
            <Button variant="outline" onClick={() => setIsRoleDialogOpen(false)}>Cancel</Button>
            <Button onClick={saveRolePermissions} disabled={updatingId === `role-${selectedRole?._id}`}>
              {updatingId === `role-${selectedRole?._id}` && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Save Defaults
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Create / Edit User Dialog */}
      <Dialog open={isUserDialogOpen} onOpenChange={setIsUserDialogOpen}>
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-hidden flex flex-col p-0">
          <form onSubmit={saveUser} className="flex flex-col h-full overflow-hidden">
            <div className="p-6 pb-4 border-b">
              <DialogTitle>{isEditingUser ? "Edit User" : "Add New User"}</DialogTitle>
              <DialogDescription className="mt-1.5">
                {isEditingUser 
                  ? "Update user profile information, role, and precise module access."
                  : "Create a new user and define their role and permissions."}
              </DialogDescription>
            </div>
            
            <div className="flex-1 overflow-y-auto">
              <Tabs defaultValue="profile" className="h-full flex flex-col">
                <div className="px-6 pt-4 border-b sticky top-0 bg-background z-10">
                  <TabsList className="w-full justify-start rounded-none h-11 bg-transparent p-0">
                    <TabsTrigger 
                      value="profile" 
                      className="rounded-none border-b-2 border-transparent data-[state=active]:border-primary data-[state=active]:bg-transparent px-4 py-2.5 h-11"
                    >
                      Profile & Role
                    </TabsTrigger>
                    <TabsTrigger 
                      value="permissions"
                      className="rounded-none border-b-2 border-transparent data-[state=active]:border-primary data-[state=active]:bg-transparent px-4 py-2.5 h-11"
                    >
                      Module Permissions
                    </TabsTrigger>
                  </TabsList>
                </div>
                
                <TabsContent value="profile" className="p-6 m-0 focus-visible:outline-none">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <Label htmlFor="name">Full Name <span className="text-destructive">*</span></Label>
                      <Input 
                        id="name" 
                        required 
                        value={userForm.name || ""}
                        onChange={(e) => setUserForm(prev => ({ ...prev, name: e.target.value }))}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="email">Email Address <span className="text-destructive">*</span></Label>
                      <Input 
                        id="email" 
                        type="email" 
                        required 
                        value={userForm.email || ""}
                        onChange={(e) => setUserForm(prev => ({ ...prev, email: e.target.value }))}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="phone">Phone Number</Label>
                      <Input 
                        id="phone" 
                        value={userForm.phone || ""}
                        onChange={(e) => setUserForm(prev => ({ ...prev, phone: e.target.value }))}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="role">System Role <span className="text-destructive">*</span></Label>
                      <Select 
                        value={userForm.role || "cashier"} 
                        onValueChange={(val) => setUserForm(prev => ({ ...prev, role: val as User["role"] }))}
                        disabled={userForm._id === currentUser?._id}
                      >
                        <SelectTrigger className="capitalize">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="admin">Admin</SelectItem>
                          <SelectItem value="manager">Manager</SelectItem>
                          <SelectItem value="accountant">Accountant</SelectItem>
                          <SelectItem value="stock_manager">Stock Manager</SelectItem>
                          <SelectItem value="cashier">Cashier</SelectItem>
                        </SelectContent>
                      </Select>
                      {userForm._id === currentUser?._id && (
                        <p className="text-[10px] text-muted-foreground mt-1">You cannot change your own role.</p>
                      )}
                    </div>
                    
                    <div className="space-y-2">
                      <Label htmlFor="password">
                        {isEditingUser ? "New Password (Optional)" : "Password"}
                        {!isEditingUser && <span className="text-destructive"> *</span>}
                      </Label>
                      <div className="relative">
                        <Input 
                          id="password" 
                          type={showPassword ? "text" : "password"}
                          placeholder={isEditingUser ? "Leave blank to keep current" : ""}
                          required={!isEditingUser}
                          value={userForm.password || ""}
                          onChange={(e) => setUserForm(prev => ({ ...prev, password: e.target.value }))}
                        />
                        <Button
                          type="button"
                          variant="ghost"
                          size="icon"
                          className="absolute right-1 top-1/2 -translate-y-1/2 h-7 w-7 hover:bg-transparent"
                          onClick={() => setShowPassword(!showPassword)}
                        >
                          {showPassword ? (
                            <EyeOff className="h-4 w-4 text-muted-foreground" />
                          ) : (
                            <Eye className="h-4 w-4 text-muted-foreground" />
                          )}
                        </Button>
                      </div>
                    </div>
                    
                    <div className="space-y-3 sm:col-span-2 mt-2 p-4 border rounded-lg bg-muted/20">
                      <div className="flex items-center justify-between">
                        <div>
                          <Label className="text-base">Account Status</Label>
                          <p className="text-sm text-muted-foreground">Determine if this user can log into the system.</p>
                        </div>
                        <Switch 
                          checked={userForm.isActive !== false}
                          onCheckedChange={(val) => setUserForm(prev => ({ ...prev, isActive: val }))}
                          disabled={userForm._id === currentUser?._id}
                        />
                      </div>
                    </div>
                  </div>
                </TabsContent>

                <TabsContent value="permissions" className="p-6 m-0 focus-visible:outline-none">
                  <div className="bg-muted/30 p-4 rounded-lg mb-6 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
                    <div className="flex items-start gap-3">
                      <Settings2 className="h-5 w-5 text-primary shrink-0 mt-0.5" />
                      <div className="text-sm text-muted-foreground">
                        Override default module access. By default, users inherit the permissions of their assigned <strong className="capitalize text-foreground">{userForm.role?.replace('_', ' ') || 'Cashier'}</strong> role. Ticking or unticking boxes below overrides those defaults specifically for <strong className="text-foreground">{userForm.name || 'this user'}</strong>.
                      </div>
                    </div>
                    <Button 
                      type="button" 
                      variant="outline" 
                      size="sm"
                      className="shrink-0"
                      onClick={() => {
                        const currentRole = String(userForm.role || 'cashier').toLowerCase();
                        const defaultRole = roles.find(r => String(r.name).toLowerCase() === currentRole);
                        
                        if (defaultRole) {
                          const perms = defaultRole.permissions || [];
                          setUserPermissions([...perms]);
                          if (perms.length === 0) {
                            toast.info(`No default permissions found for ${userForm.role || 'Cashier'} role.`);
                          } else {
                            toast.success(`Loaded ${perms.length} default permissions.`);
                          }
                        } else {
                          setUserPermissions([]);
                          toast.error(`Role configuration for ${userForm.role || 'Cashier'} not found.`);
                        }
                      }}
                    >
                      Load Defaults
                    </Button>
                  </div>
                  
                  <div className="grid grid-cols-2 sm:grid-cols-3 gap-y-5 gap-x-4">
                    {ALL_MODULES.map(module => (
                      <div key={module} className="flex items-center space-x-3">
                        <Checkbox 
                          id={`unified-mod-${module}`} 
                          checked={userPermissions.includes(module)}
                          onCheckedChange={() => toggleUserPermission(module)}
                        />
                        <label 
                          htmlFor={`unified-mod-${module}`}
                          className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 cursor-pointer"
                        >
                          {formatModuleName(module)}
                        </label>
                      </div>
                    ))}
                  </div>
                </TabsContent>
              </Tabs>
            </div>

            <div className="p-6 py-4 border-t bg-muted/10 mt-auto flex justify-end gap-2">
              <Button type="button" variant="outline" onClick={() => setIsUserDialogOpen(false)}>Cancel</Button>
              <Button type="submit" disabled={updatingId === "user-save"}>
                {updatingId === "user-save" && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {isEditingUser ? "Save Changes" : "Create User"}
              </Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Are you absolutely sure?</DialogTitle>
            <DialogDescription>
              This action cannot be undone. This will permanently delete <strong>{userToDelete?.name}</strong> from the system and remove their data from our servers.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter className="mt-4 gap-2 sm:gap-0">
            <Button variant="outline" onClick={() => setIsDeleteDialogOpen(false)}>Cancel</Button>
            <Button variant="destructive" onClick={handleDeleteUser} disabled={updatingId === `user-del-${userToDelete?._id}`}>
              {updatingId === `user-del-${userToDelete?._id}` && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Delete User
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
