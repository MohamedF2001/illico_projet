import '../models/vehicule_model.dart';
import '../../domain/entities/vehicule_entity.dart';
extension VehiculeModelMapper on VehiculeModel { VehiculeEntity toEntity() => this; }
extension VehiculeEntityMapper on VehiculeEntity { VehiculeModel toModel() => VehiculeModel(id: id, type: type, tarifBase: tarifBase, coutParKm: coutParKm, commission: commission, description: description, actif: actif); }
