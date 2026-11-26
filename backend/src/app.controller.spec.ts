import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('health & time', () => {
    it('should return ok status', () => {
      const health = appController.getHealth();
      expect(health.status).toBe('ok');
    });

    it('should return serverNow ISO timestamp', () => {
      const time = appController.getServerTime();
      expect(typeof time.serverNow).toBe('string');
    });
  });
});
