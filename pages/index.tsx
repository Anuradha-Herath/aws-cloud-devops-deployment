import Head from 'next/head';
import { useEffect, useState } from 'react';

export default function Home() {
  const [serverTime, setServerTime] = useState<string>('');
  const [systemInfo, setSystemInfo] = useState<any>(null);

  useEffect(() => {
    // Fetch server info on component mount
    fetch('/api/info')
      .then(res => res.json())
      .then(data => {
        setServerTime(data.timestamp);
        setSystemInfo(data);
      })
      .catch(err => console.error('Failed to fetch server info:', err));
  }, []);

  return (
    <>
      <Head>
        <title>Cloud DevOps Web App</title>
        <meta name="description" content="Dockerized Next.js app with Nginx and Netdata monitoring" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main style={styles.main}>
        <div style={styles.container}>
          <h1 style={styles.title}>
            🚀 Cloud DevOps Web Application
          </h1>

          <p style={styles.description}>
            Deployed with Docker, Nginx, and Netdata Monitoring
          </p>

          <div style={styles.grid}>
            <div style={styles.card}>
              <h2>🐳 Docker</h2>
              <p>Containerized application for consistent deployment</p>
            </div>

            <div style={styles.card}>
              <h2>⚙️ Nginx</h2>
              <p>Reverse proxy for efficient request handling</p>
            </div>

            <div style={styles.card}>
              <h2>📊 Netdata</h2>
              <p>Real-time performance monitoring</p>
            </div>

            <div style={styles.card}>
              <h2>☁️ AWS EC2</h2>
              <p>Cloud-deployed on Ubuntu Linux server</p>
            </div>
          </div>

          {systemInfo && (
            <div style={styles.info}>
              <h3>Server Information</h3>
              <p><strong>Status:</strong> {systemInfo.status}</p>
              <p><strong>Server Time:</strong> {serverTime}</p>
              <p><strong>Environment:</strong> {systemInfo.environment}</p>
              <p><strong>Node Version:</strong> {systemInfo.nodeVersion}</p>
            </div>
          )}

          <div style={styles.links}>
            <a href="/api/health" style={styles.link}>Health Check →</a>
            <a href="/api/info" style={styles.link}>System Info →</a>
          </div>
        </div>
      </main>
    </>
  );
}

const styles: { [key: string]: React.CSSProperties } = {
  main: {
    minHeight: '100vh',
    padding: '4rem 0',
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    fontFamily: '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, sans-serif',
  },
  container: {
    maxWidth: '1200px',
    margin: '0 auto',
    padding: '0 2rem',
  },
  title: {
    fontSize: '3.5rem',
    fontWeight: 'bold',
    textAlign: 'center',
    color: '#ffffff',
    marginBottom: '1rem',
  },
  description: {
    fontSize: '1.5rem',
    textAlign: 'center',
    color: '#f0f0f0',
    marginBottom: '3rem',
  },
  grid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
    gap: '2rem',
    marginBottom: '3rem',
  },
  card: {
    background: 'rgba(255, 255, 255, 0.1)',
    backdropFilter: 'blur(10px)',
    borderRadius: '12px',
    padding: '2rem',
    color: '#ffffff',
    border: '1px solid rgba(255, 255, 255, 0.2)',
    transition: 'transform 0.3s ease',
  },
  info: {
    background: 'rgba(255, 255, 255, 0.15)',
    backdropFilter: 'blur(10px)',
    borderRadius: '12px',
    padding: '2rem',
    color: '#ffffff',
    border: '1px solid rgba(255, 255, 255, 0.2)',
    marginBottom: '2rem',
  },
  links: {
    display: 'flex',
    justifyContent: 'center',
    gap: '2rem',
    flexWrap: 'wrap',
  },
  link: {
    padding: '0.75rem 2rem',
    background: 'rgba(255, 255, 255, 0.2)',
    color: '#ffffff',
    textDecoration: 'none',
    borderRadius: '8px',
    border: '1px solid rgba(255, 255, 255, 0.3)',
    fontWeight: '600',
    transition: 'all 0.3s ease',
  },
};
