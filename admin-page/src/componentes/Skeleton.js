import React from 'react';

export const SkeletonTarjeta = () => (
  <div style={{
    backgroundColor: 'white', padding: '25px', borderRadius: '8px',
    flex: '1', minWidth: '200px', borderTop: '4px solid #e5e7eb',
    boxShadow: '0 1px 3px rgba(0,0,0,0.05)'
  }}>
    <div className="skeleton" style={{ height: '12px', width: '55%', marginBottom: '16px', borderRadius: '4px' }} />
    <div className="skeleton" style={{ height: '38px', width: '35%', borderRadius: '4px' }} />
  </div>
);

export const SkeletonFila = ({ columnas = 5 }) => (
  <tr>
    {Array.from({ length: columnas }).map((_, i) => (
      <td key={i} style={{ padding: '16px 20px' }}>
        <div className="skeleton" style={{
          height: '14px', borderRadius: '4px',
          width: i === 0 ? '40px' : i === columnas - 1 ? '70px' : `${60 + Math.random() * 30}%`
        }} />
      </td>
    ))}
  </tr>
);

export const SkeletonBloque = ({ alto = '300px' }) => (
  <div className="skeleton" style={{ width: '100%', height: alto, borderRadius: '8px' }} />
);
