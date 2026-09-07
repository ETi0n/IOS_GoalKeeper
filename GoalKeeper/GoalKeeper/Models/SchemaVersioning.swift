import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    // 버전 1로 현재 모델 5개 묶어둠
    static var models: [any PersistentModel.Type] {
        [Goal.self, Milestone.self, Category.self, TaskItem.self, Criterion.self]
    }
}

enum GoalKeeperMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        [] // 추후 업데이트로 버전 2로 변경 시 "V1에서 V2로 변화하는 단계"로써 추가
        // .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self) // (단순 변화)
        // .custom(...) // (복잡한 변환)
    }
}
