import '../models/livraison_model.dart';
import '../../domain/entities/livraison_entity.dart';
extension LivraisonModelMapper on LivraisonModel { LivraisonEntity toEntity() => this; }
