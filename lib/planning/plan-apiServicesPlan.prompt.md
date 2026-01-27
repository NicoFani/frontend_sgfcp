# API Services Implementation Plan

## Existing Services (Need Completion)

### trip_service.dart:
- [x] getTrips()
- [x] getTrip()
- [x] getCurrentTrip()
- [x] getNextTrip()
- [x] updateTrip()
- [x] createTrip()
- [x] deleteTrip()
- [x] getTripsByDriver()
- [x] getTripsByState()

### driver_service.dart:
- [x] getDrivers()
- [x] getDriverById()
- [x] createDriver()
- [x] updateDriver()
- [x] deleteDriver()

### client_service.dart:
- [x] getClients()
- [x] getClientById()
- [x] createClient()
- [x] updateClient()
- [x] deleteClient()

### load_owner_service.dart:
- [x] getLoadOwners()
- [x] getLoadOwnerById()
- [x] createLoadOwner()
- [x] updateLoadOwner()
- [x] deleteLoadOwner()

### advance_payment_service.dart:
- [x] getAdvancePayments()
- [x] getAdvancePayment()
- [x] createAdvancePayment()
- [x] updateAdvancePayment()
- [x] deleteAdvancePayment()

### expense_service.dart:
- [x] getExpensesByTrip()
- [x] getAllExpenses()
- [x] getExpenseById()
- [x] createExpense()
- [x] updateExpense()
- [x] deleteExpense()
- [x] getExpensesByType()

### auth_service.dart:
- [x] login()
- [x] register()
- [x] refreshToken()
- [x] getCurrentUser()
- [x] logout()
- [ ] updateProfile() *(requires backend implementation)*
- [ ] resetPassword() *(requires backend implementation)*

## Missing Services (Need Creation)

### truck_service.dart:
- [x] getTrucks()
- [x] getTruckById()
- [x] createTruck()
- [x] updateTruck()
- [x] deleteTruck()

### driver_truck_service.dart:
- [x] getDriverTrucks()
- [x] getDriverTruckById()
- [x] assignDriverToTruck()
- [x] removeDriverFromTruck()
- [x] getTrucksByDriver()
- [ ] getDriverByTruck() *(requires backend implementation)*

### payroll_export_service.dart:
- [ ] exportPayrollPdf()
- [ ] exportPayrollExcel()

### payroll_other_item_service.dart:
- [x] createOtherItem()
- [x] getAllOtherItems()
- [x] getOtherItemsByPeriodAndDriver()
- [x] updateOtherItem()
- [x] deleteOtherItem()

### payroll_period_service.dart:
- [x] getAllPeriods()
- [x] getPeriodById()
- [ ] createPayrollPeriod()
- [ ] updatePayrollPeriod()
- [ ] closePayrollPeriod()

### payroll_summary_service.dart:
- [x] generateSummary()
- [x] getSummariesByPeriod()
- [x] getAllSummaries()
- [x] getSummaryById()
- [x] recalculateSummary()
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

## Implementation Priority

### High Priority (Core Functionality):
1. ~~Complete expense_service.dart - Full CRUD operations~~ ✅ COMPLETED
2. ~~Complete client_service.dart - Full CRUD operations~~ ✅ COMPLETED
3. ~~Complete driver_service.dart - Full CRUD operations~~ ✅ COMPLETED
4. ~~Complete load_owner_service.dart - Full CRUD operations~~ ✅ COMPLETED
5. ~~Create truck_service.dart - Vehicle management~~ ✅ COMPLETED
6. ~~Create driver_truck_service.dart - Driver-vehicle assignments~~ ✅ COMPLETED

### Medium Priority (Admin Features):
7. ~~Complete auth_service.dart - User management functions~~ ✅ COMPLETED
8. Create user_service.dart - Admin user management
9. Create summary_service.dart - Monthly summaries
10. ~~Complete payroll_other_item_service.dart - Other payroll concepts~~ ✅ COMPLETED

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