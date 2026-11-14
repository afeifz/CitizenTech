import { useEffect, useState } from 'react'
import './App.css'

const initialSensors = [
  { id: 'SEN-001', name: 'Rio principal', location: 'Setor Norte', level: 42, status: 'normal' },
  { id: 'SEN-002', name: 'Canal urbano', location: 'Setor Central', level: 76, status: 'alerta' },
  { id: 'SEN-003', name: 'Área residencial', location: 'Setor Sul', level: 91, status: 'perigo' },
]

const initialEvents = [
  { time: 'Agora', title: 'Sistema iniciado', description: 'Monitoramento simulado em execução.', type: 'normal' },
  { time: '14:32', title: 'Nível elevado detectado', description: 'Canal urbano atingiu 76% da capacidade.', type: 'alerta' },
  { time: '14:18', title: 'Risco de alagamento', description: 'Área residencial atingiu nível crítico.', type: 'perigo' },
  { time: '13:55', title: 'Sensores verificados', description: 'Todos os sensores estão respondendo.', type: 'normal' },
]

function App() {
  const [sensors, setSensors] = useState(initialSensors)
  const [events, setEvents] = useState(initialEvents)
  const [lastUpdate, setLastUpdate] = useState(new Date())

  useEffect(() => {
    const timer = setInterval(() => {
      setSensors(current =>
        current.map(sensor => {
          const variation = Math.floor(Math.random() * 7) - 3
          const level = Math.max(10, Math.min(100, sensor.level + variation))
          const status = level >= 85 ? 'perigo' : level >= 65 ? 'alerta' : 'normal'
          return { ...sensor, level, status }
        })
      )
      setLastUpdate(new Date())
    }, 5000)

    return () => clearInterval(timer)
  }, [])

  const average = Math.round(
    sensors.reduce((sum, sensor) => sum + sensor.level, 0) / sensors.length
  )

  const criticalCount = sensors.filter(sensor => sensor.status === 'perigo').length
  const warningCount = sensors.filter(sensor => sensor.status === 'alerta').length

  const overallStatus = criticalCount > 0 ? 'perigo' : warningCount > 0 ? 'alerta' : 'normal'

  const statusLabels = {
    normal: 'Situação normal',
    alerta: 'Atenção necessária',
    perigo: 'Risco elevado',
  }

  function simulateAlert() {
    const now = new Date().toLocaleTimeString('pt-BR', {
      hour: '2-digit',
      minute: '2-digit',
    })

    setEvents(current => [
      {
        time: now,
        title: 'Alerta de teste gerado',
        description: 'Evento demonstrativo registrado pelo operador.',
        type: 'alerta',
      },
      ...current,
    ].slice(0, 8))
  }

  return (
    <main className="app">
      <aside className="sidebar">
        <div className="brand">
          <div className="brand-icon">C</div>
          <div>
            <strong>CitizenTech</strong>
            <span>MONITORAMENTO URBANO</span>
          </div>
        </div>

        <div className="menu-label">MENU PRINCIPAL</div>
        <nav>
          <a className="nav-item active" href="#overview">▦ <span>Painel geral</span></a>
          <a className="nav-item" href="#sensors">◉ <span>Sensores</span></a>
          <a className="nav-item" href="#events">◷ <span>Histórico de eventos</span></a>
        </nav>

        <div className="sidebar-bottom">
          <div className="connection">
            <span className="pulse" />
            <div>
              <strong>Sistema online</strong>
              <small>Monitoramento ativo</small>
            </div>
          </div>
          <small className="version">CitizenTech · Versão 1.0</small>
        </div>
      </aside>

      <section className="content" id="overview">
        <header className="topbar">
          <div>
            <div className="breadcrumb">Monitoramento / <strong>Painel geral</strong></div>
            <h1>Painel de monitoramento</h1>
            <p>Acompanhe os níveis de água e os riscos de alagamento.</p>
          </div>
          <div className="topbar-right">
            <span className="live"><span className="pulse" /> AO VIVO</span>
            <div className="avatar">CT</div>
          </div>
        </header>

        <section className={`status-banner ${overallStatus}`}>
          <div className="status-symbol">
            {overallStatus === 'perigo' ? '!' : overallStatus === 'alerta' ? '⚠' : '✓'}
          </div>
          <div>
            <span>STATUS GERAL DA REGIÃO</span>
            <h2>{statusLabels[overallStatus]}</h2>
            <p>
              {overallStatus === 'perigo'
                ? 'Um ou mais sensores registraram níveis críticos de água.'
                : overallStatus === 'alerta'
                  ? 'Existem pontos que exigem atenção.'
                  : 'Nenhum risco significativo identificado no momento.'}
            </p>
          </div>
          <div className="banner-time">
            <span>ÚLTIMA ATUALIZAÇÃO</span>
            <strong>{lastUpdate.toLocaleTimeString('pt-BR')}</strong>
          </div>
        </section>

        <section className="stats-grid">
          <article className="stat-card">
            <div className="stat-heading">NÍVEL MÉDIO DA ÁGUA <span>≈</span></div>
            <div className="stat-value">{average}<small>%</small></div>
            <div className="stat-foot">Média dos sensores ativos</div>
          </article>
          <article className="stat-card">
            <div className="stat-heading">SENSORES ATIVOS <span>◉</span></div>
            <div className="stat-value">{sensors.length}<small> / 3</small></div>
            <div className="stat-foot"><span className="green-text">Todos operacionais</span></div>
          </article>
          <article className="stat-card">
            <div className="stat-heading">ALERTAS <span>⚠</span></div>
            <div className="stat-value warning-text">{warningCount + criticalCount}</div>
            <div className="stat-foot">Pontos que exigem atenção</div>
          </article>
          <article className="stat-card">
            <div className="stat-heading">PONTOS CRÍTICOS <span>⌖</span></div>
            <div className="stat-value danger-text">{criticalCount}</div>
            <div className="stat-foot">Níveis acima de 85%</div>
          </article>
        </section>

        <section className="section" id="sensors">
          <div className="section-heading">
            <div>
              <h2>Monitoramento dos sensores</h2>
              <p>Acompanhamento individual dos pontos de coleta.</p>
            </div>
            <span className="updated">Atualização automática · 5 segundos</span>
          </div>

          <div className="sensor-grid">
            {sensors.map(sensor => (
              <article className="sensor-card" key={sensor.id}>
                <div className="sensor-top">
                  <div className="sensor-icon">⌁</div>
                  <span className={`tag ${sensor.status}`}>{statusLabels[sensor.status]}</span>
                </div>
                <h3>{sensor.name}</h3>
                <p className="sensor-location">⌖ {sensor.location}</p>
                <div className="level-row">
                  <span>Nível de água</span>
                  <strong>{sensor.level}%</strong>
                </div>
                <div className="progress">
                  <div className={`progress-fill ${sensor.status}`} style={{ width: `${sensor.level}%` }} />
                </div>
                <div className="sensor-footer">
                  <span>{sensor.id}</span>
                  <span>● Conectado</span>
                </div>
              </article>
            ))}
          </div>
        </section>

        <section className="section events-section" id="events">
          <div className="section-heading">
            <div>
              <h2>Histórico de eventos</h2>
              <p>Registro das últimas atividades do monitoramento.</p>
            </div>
            <button className="action-button" onClick={simulateAlert}>+ Simular alerta</button>
          </div>

          <div className="event-list">
            {events.map((event, index) => (
              <article className="event-item" key={`${event.time}-${index}`}>
                <div className={`event-dot ${event.type}`} />
                <div className="event-info">
                  <strong>{event.title}</strong>
                  <p>{event.description}</p>
                </div>
                <time>{event.time}</time>
              </article>
            ))}
          </div>
        </section>

        <footer>
          <span>CitizenTech © 2026 · Sistema demonstrativo de alerta de alagamentos</span>
          <span>Dados simulados para fins acadêmicos</span>
        </footer>
      </section>
    </main>
  )
}

export default App
