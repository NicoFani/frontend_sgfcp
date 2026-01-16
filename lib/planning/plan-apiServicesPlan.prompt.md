# API Services Implementation Plan

## Existing Services (Need Completion)

### trip_service.dart:
- [x] getTrips()
- [x] getTrip()
- [x] getCurrentTrip()
- [x] getNextTrip()
- [x] updateTrip()
- [x] createTrip()
- [ ] deleteTrip()
- [ ] getTripsByDriver()
- [ ] getTripsByState()

### driver_service.dart:
- [x] getDrivers()
- [ ] getDriverById()
- [ ] createDriver()
- [ ] updateDriver()
- [ ] deleteDriver()

### client_service.dart:
- [x] getClients()
- [ ] getClientById()
- [ ] createClient()
- [ ] updateClient()
- [ ] deleteClient()

### load_owner_service.dart:
- [x] getLoadOwners()
- [ ] getLoadOwnerById()
- [ ] createLoadOwner()
- [ ] updateLoadOwner()
- [ ] deleteLoadOwner()

### advance_payment_service.dart:
- [x] getAdvancePayments()
- [x] getAdvancePayment()
- [x] createAdvancePayment()
- [x] updateAdvancePayment()
- [x] deleteAdvancePayment()

### expense_service.dart:
- [x] getExpensesByTrip()
- [ ] getAllExpenses()
- [ ] getExpenseById()
- [ ] createExpense()
- [ ] updateExpense()
- [ ] deleteExpense()
- [ ] getExpensesByType()

### auth_service.dart:
- [x] login()
- [x] register()
- [ ] refreshToken()
- [ ] getCurrentUser()
- [ ] logout()
- [ ] updateProfile()
- [ ] resetPassword()

## Missing Services (Need Creation)

### truck_service.dart:
- [ ] getTrucks()
- [ ] getTruckById()
- [ ] createTruck()
- [ ] updateTruck()
- [ ] deleteTruck()

### driver_truck_service.dart:
- [ ] getDriverTrucks()
- [ ] getDriverTruckById()
- [ ] assignDriverToTruck()
- [ ] removeDriverFromTruck()
- [ ] getTrucksByDriver()
- [ ] getDriversByTruck()

### summary_service.dart (Monthly Summaries):
- [ ] getMonthlySummaries()
- [ ] getMonthlySummaryById()
- [ ] generateMonthlySummary()
- [ ] updateMonthlySummary() (Used also to approve/reject)
- [ ] exportMonthlySummaryPdf()
- [ ] exportMonthlySummaryExcel()

### payroll_concept_service.dart:
- [ ] getPayrollConcepts()
- [ ] getPayrollConceptById()
- [ ] createPayrollConcept()
- [ ] updatePayrollConcept()
- [ ] deletePayrollConcept()

### payroll_calculation_service.dart:
- [ ] calculatePayroll()
- [ ] getPayrollCalculation()
- [ ] updatePayrollCalculation()

### payroll_export_service.dart:
- [ ] exportPayrollPdf()
- [ ] exportPayrollExcel()
- [ ] exportPayrollCsv()

### payroll_period_service.dart:
- [ ] getPayrollPeriods()
- [ ] getPayrollPeriodById()
- [ ] createPayrollPeriod()
- [ ] updatePayrollPeriod()
- [ ] closePayrollPeriod()

### payroll_settings_service.dart:
- [ ] getPayrollSettings()
- [ ] updatePayrollSettings()
- [ ] getSummaryGenerationSettings()
- [ ] updateSummaryGenerationSettings()

### payroll_summary_service.dart:
- [ ] getPayrollSummaries()
- [ ] getPayrollSummaryById()
- [ ] generatePayrollSummary()
- [ ] updatePayrollSummary()

### user_service.dart (App User Management):
- [ ] getUsers()
- [ ] getUserById()
- [ ] createUser()
- [ ] updateUser()
- [ ] deleteUser()
- [ ] changePassword()
- [ ] resetUserPassword()

### commission_percentage_service.dart:
- [ ] getCommissionPercentages()
- [ ] getCommissionPercentageById()
- [ ] createCommissionPercentage()
- [ ] updateCommissionPercentage()
- [ ] deleteCommissionPercentage()

### driver_commission_service.dart:
- [ ] getDriverCommissions()
- [ ] getDriverCommissionById()
- [ ] createDriverCommission()
- [ ] updateDriverCommission()
- [ ] deleteDriverCommission()

### driver_guaranteed_minimum_service.dart (guaranteed minimum is an entity with id, driverId, amount, startDate, endDate):
- [ ] getDriverGuaranteedMinimums()
- [ ] getDriverGuaranteedMinimumById()
- [ ] createDriverGuaranteedMinimum()
- [ ] updateDriverGuaranteedMinimum()
- [ ] deleteDriverGuaranteedMinimum()

### driver_documentation_service.dart:
- [ ] getDriverDocumentations()
- [ ] getDriverDocumentationById()
- [ ] createDriverDocumentation()
- [ ] updateDriverDocumentation()
- [ ] deleteDriverDocumentation()

### truck_Documentation_service.dart:
- [ ] getTruckDocumentations()
- [ ] getTruckDocumentationById()
- [ ] createTruckDocumentation()
- [ ] updateTruckDocumentation()
- [ ] deleteTruckDocumentation()

## Implementation Priority

### High Priority (Core Functionality):
1. Complete expense_service.dart - Full CRUD operations
2. Complete client_service.dart - Full CRUD operations
3. Complete driver_service.dart - Full CRUD operations
4. Complete load_owner_service.dart - Full CRUD operations
5. Create truck_service.dart - Vehicle management
6. Create driver_truck_service.dart - Driver-vehicle assignments

### Medium Priority (Admin Features):
7. Complete auth_service.dart - User management functions
8. Create user_service.dart - Admin user management
9. Create summary_service.dart - Monthly summaries
10. Create payroll_Concept_service.dart - Payroll concepts

### Low Priority (Advanced Features):
11. Create payroll_calculation_service.dart - Payroll calculations
12. Create payroll_export_service.dart - Export functionality
13. Create payroll_period_service.dart - Period management
14. Create payroll_settings_service.dart - Settings management
16. Create commission_percentage_service.dart - Commission settings
17. Create driver_commission_service.dart - Driver commissions

## Notes:
- All services should use the standardized ApiResponseHandler for consistent error handling
- Authentication headers should be included for protected endpoints
- Response data should be properly parsed into model objects
- Error handling should provide user-friendly messages in Spanish
- New files should follow the existing project structure and naming conventions
- New files should use environmental variables for API base URL configuration
<parameter name="filePath">untitled:plan-apiServicesPlan.prompt.md