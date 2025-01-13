import '../models/fault_record.dart';

List<FaultRecord> mockFaultRecords = [
  FaultRecord(
    date: '2025-01-10',
    faultDescription: 'Error en el sistema de frenos',
    faultCode: 'FRE-001',
    solution: 'Cambio de pastillas de freno',
    changedParts: ['Pastillas de freno', 'Líquido de frenos'],
    mechanicName: 'Juan Pérez',
    cost: 120.50,
    // notes eliminadas
  ),
  FaultRecord(
    date: '2025-01-08',
    faultDescription: 'Fallo en el motor',
    faultCode: 'MOT-003',
    solution: 'Reparación de bujías',
    changedParts: ['Bujías'],
    mechanicName: 'María López',
    cost: 80.00,
    // notes eliminadas
  ),
];
