import { DataSource } from 'typeorm';

// import { SeedWorkspaceId } from 'src/database/typeorm-seeds/core/workspaces';

const tableName = 'user';

export const DEV_SEED_USER_IDS = {
  TIM: '20202020-9e3b-46d4-a556-88b9ddc2b034',
  JONY: '20202020-3957-4908-9c36-2929a23f8357',
  PHIL: '20202020-7169-42cf-bc47-1cfef15264b8',
};

export const seedUsers = async (
  workspaceDataSource: DataSource,
  schemaName: string,
  workspaceId: string,
) => {
  await workspaceDataSource
    .createQueryBuilder()
    .insert()
    .into(`${schemaName}.${tableName}`, [
      'id',
      'firstName',
      'lastName',
      'email',
      'passwordHash',
      'defaultWorkspaceId',
    ])
    .orIgnore()
    .values([
      {
        id: DEV_SEED_USER_IDS.TIM,
        firstName: 'DATX',
        lastName: 'Admin',
        email: 'admin@datx.com.vn',
        passwordHash:
          '$2b$10$4PuoZJ6vBQWAVIkpGbnlpOWxSmF6a8OPhWk3xO5eKkmi8jpALvyMq', // Applecar2025
        defaultWorkspaceId: workspaceId,
      },
      {
        id: DEV_SEED_USER_IDS.JONY,
        firstName: 'Dat',
        lastName: 'Nguyen',
        email: 'dat.nguyen@datx.com.vn',
        passwordHash:
          '$2b$10$CrAVxSKRJs5YDXxUEuLn.OqvLqR1V27W/ODf.Iv1kVSRlmR97MXeC', // Applecar2025
        defaultWorkspaceId: workspaceId,
      },
      {
        id: DEV_SEED_USER_IDS.PHIL,
        firstName: 'Hien',
        lastName: 'Hoang',
        email: 'hien.hoang@datx.com.vn',
        passwordHash:
          '$2b$10$BbWxet/3sGR2/w3jEjTktOLMlnoiIod6fkQiqL/.sKCDwzxGs5ykq', // Applecar2025
        defaultWorkspaceId: workspaceId,
      },
    ])
    .execute();
};

export const deleteUsersByWorkspace = async (
  workspaceDataSource: DataSource,
  schemaName: string,
  workspaceId: string,
) => {
  await workspaceDataSource
    .createQueryBuilder()
    .delete()
    .from(`${schemaName}.${tableName}`)
    .where(`"${tableName}"."defaultWorkspaceId" = :workspaceId`, {
      workspaceId,
    })
    .execute();
};
