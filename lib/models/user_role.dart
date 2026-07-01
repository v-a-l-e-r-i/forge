enum UserRole {
  employee,
  teamLead,
  admin;

  String toFirestore() {
    switch (this) {
      case UserRole.employee:
        return 'employee';
      case UserRole.teamLead:
        return 'team_lead';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromFirestore(String value) {
    switch (value) {
      case 'team_lead':
        return UserRole.teamLead;
      case 'admin':
        return UserRole.admin;
      case 'employee':
      default:
        return UserRole.employee;
    }
  }

  String get label {
    switch (this) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.teamLead:
        return 'Team lead';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
