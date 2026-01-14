# Configuración AWS Free Tier

Este proyecto está optimizado para usar el **AWS Free Tier** siempre que sea posible.

## Recursos y Límites del Free Tier

### ✅ Lambda (Permanente - Sin expiración)
- **1 millón de requests gratis por mes**
- **400,000 GB-segundos de tiempo de cómputo gratis por mes**
- Configuración actual: 128MB de memoria
  - Con 128MB: ~3,125,000 invocaciones de 1 segundo gratis/mes
  - Si necesitas más memoria, aumenta pero reducirás el número de invocaciones gratis

### ✅ API Gateway HTTP API (Permanente - Sin expiración)
- **1 millón de requests HTTP/HTTPS gratis por mes**
- HTTP API es más económico que REST API
- Throttling configurado: 5 requests/segundo (burst: 10)

### ✅ S3 (Primer año)
- **5 GB de almacenamiento estándar gratis**
- **20,000 GET requests gratis por mes**
- **2,000 PUT requests gratis por mes**
- Lifecycle rules configuradas para eliminar objetos antiguos y reducir costos

### ✅ CloudFront (Primer año)
- **50 GB de transferencia de datos salientes gratis por mes**
- **2,000,000 de requests HTTP/HTTPS gratis por mes**
- Cache configurado a 24 horas (default_ttl) para reducir requests a S3

### ⚠️ Route53 (No hay Free Tier, pero es barato)
- **$0.50 por zona alojada por mes**
- Solo se usa si `use_custom_domain = true`

### ✅ ACM (Certificados SSL)
- **Gratis** - Los certificados SSL/TLS no tienen costo

### ✅ IAM
- **Gratis** - Gestión de usuarios, roles y políticas

## Estimación de Costos (dentro del Free Tier)

### Primer año:
- **$0.00/mes** si usas menos de:
  - 1M requests Lambda/mes
  - 1M requests API Gateway/mes
  - 5GB S3 almacenamiento
  - 50GB CloudFront transferencia
  - 2M requests CloudFront/mes

### Después del primer año:
- **~$0.00-5.00/mes** (dependiendo del uso)
  - Lambda: Gratis (permanente)
  - API Gateway: Gratis (permanente)
  - S3: ~$0.023/GB después de 5GB
  - CloudFront: ~$0.085/GB después de 50GB

## Optimizaciones Aplicadas

1. **Lambda**: Memoria mínima (128MB) para maximizar tiempo de cómputo gratis
2. **S3**: Lifecycle rules para eliminar objetos antiguos automáticamente
3. **CloudFront**: Cache extendido (24 horas) para reducir requests a S3
4. **API Gateway**: HTTP API en lugar de REST API (más económico)

## Monitoreo de Uso

Para monitorear tu uso del Free Tier:
1. Ve a AWS Billing Dashboard
2. Revisa "Free Tier Usage" para ver cuánto has usado
3. Configura alertas de billing si te acercas a los límites

## Notas Importantes

- El Free Tier de S3 y CloudFront expira después de 12 meses
- Lambda y API Gateway tienen Free Tier permanente
- Si excedes los límites, se aplicarán cargos normales
- Considera usar AWS Budgets para alertas de costos
