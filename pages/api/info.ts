import type { NextApiRequest, NextApiResponse } from 'next';
import os from 'os';

type InfoResponse = {
  status: string;
  timestamp: string;
  uptime: number;
  environment: string;
  nodeVersion: string;
  platform: string;
  hostname: string;
  memory: {
    total: string;
    free: string;
    used: string;
  };
};

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<InfoResponse>
) {
  const totalMem = os.totalmem();
  const freeMem = os.freemem();
  const usedMem = totalMem - freeMem;

  res.status(200).json({
    status: 'operational',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    nodeVersion: process.version,
    platform: os.platform(),
    hostname: os.hostname(),
    memory: {
      total: `${(totalMem / 1024 / 1024 / 1024).toFixed(2)} GB`,
      free: `${(freeMem / 1024 / 1024 / 1024).toFixed(2)} GB`,
      used: `${(usedMem / 1024 / 1024 / 1024).toFixed(2)} GB`,
    },
  });
}
