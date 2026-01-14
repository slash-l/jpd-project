import { PlatformContext, PlatformClients, PlatformHttpClient } from 'jfrog-workers';
import { AfterDownloadRequest } from './types';
import { createMock, DeepMocked } from '@golevelup/ts-jest';
import runWorker from './worker';

describe("slash-after-download-worker tests", () => {
    let context: DeepMocked<PlatformContext>;
    let request: DeepMocked<AfterDownloadRequest>;

    beforeEach(() => {
        context = createMock<PlatformContext>({
            clients: createMock<PlatformClients>({
                platformHttp: createMock<PlatformHttpClient>({
                    get: jest.fn().mockResolvedValue({ status: 200 })
                })
            })
        });
        request = createMock<AfterDownloadRequest>();
    })

    it('should run', async () => {
        await expect(runWorker(context, request)).resolves.toEqual(expect.objectContaining({
            message: expect.anything(),
        }))
    })
});