import React, { useState, useEffect } from 'react';
import QRCode from 'qrcode';
import { Html5QrcodeScanner } from 'html5-qrcode';
import { QrCode, History, X } from 'lucide-react';

type Tab = 'generate' | 'scan' | 'history';
type HistoryItem = {
  id: string;
  type: 'generated' | 'scanned';
  content: string;
  timestamp: number;
};

function App() {
  const [activeTab, setActiveTab] = useState<Tab>('generate');
  const [text, setText] = useState('');
  const [qrCodeUrl, setQrCodeUrl] = useState('');
  const [history, setHistory] = useState<HistoryItem[]>(() => {
    const saved = localStorage.getItem('qrHistory');
    return saved ? JSON.parse(saved) : [];
  });

  useEffect(() => {
    localStorage.setItem('qrHistory', JSON.stringify(history));
  }, [history]);

  const generateQRCode = () => {
    if (text) {
      QRCode.toDataURL(text)
        .then(url => {
          setQrCodeUrl(url);
          addToHistory('generated', text);
        })
        .catch(err => {
          console.error(err);
        });
    }
  };

  useEffect(() => {
    if (activeTab === 'scan') {
      const scanner = new Html5QrcodeScanner('reader', {
        qrbox: {
          width: 250,
          height: 250,
        },
        fps: 5,
      }, false);

      scanner.render(success, error);

      function success(result: string) {
        scanner.clear();
        addToHistory('scanned', result);
        setActiveTab('history');
      }

      function error(err: any) {
        console.warn(err);
      }

      return () => {
        scanner.clear();
      };
    }
  }, [activeTab]);

  const addToHistory = (type: 'generated' | 'scanned', content: string) => {
    const newItem: HistoryItem = {
      id: Date.now().toString(),
      type,
      content,
      timestamp: Date.now(),
    };
    setHistory(prev => [newItem, ...prev]);
  };

  

  const removeHistoryItem = (id: string) => {
    setHistory(prev => prev.filter(item => item.id !== id));
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <div className="max-w-3xl mx-auto p-6">
        <div className="bg-white rounded-lg shadow-lg overflow-hidden">
          {/* Tabs */}
          <div className="flex border-b">
            <button
              className={`flex items-center px-6 py-3 ${
                activeTab === 'generate'
                  ? 'bg-blue-500 text-white'
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
              onClick={() => setActiveTab('generate')}
            >
              <QrCode className="w-5 h-5 mr-2" />
              Generate
            </button>
            <button
              className={`flex items-center px-6 py-3 ${
                activeTab === 'scan'
                  ? 'bg-blue-500 text-white'
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
              onClick={() => setActiveTab('scan')}
            >
              <QrCode className="w-5 h-5 mr-2" />
              Scan
            </button>
            <button
              className={`flex items-center px-6 py-3 ${
                activeTab === 'history'
                  ? 'bg-blue-500 text-white'
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
              onClick={() => setActiveTab('history')}
            >
              <History className="w-5 h-5 mr-2" />
              History
            </button>
          </div>

          {/* Content */}
          <div className="p-6">
            {activeTab === 'generate' && (
              <div className="space-y-4">
                <div>
                  <label htmlFor="text" className="block text-sm font-medium text-gray-700">
                    Enter text or URL
                  </label>
                  <input
                    type="text"
                    id="text"
                    value={text}
                    onChange={(e) => setText(e.target.value)}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    placeholder="Enter text to generate QR code"
                  />
                </div>
                <button
                  onClick={generateQRCode}
                  className="w-full bg-blue-500 text-white py-2 px-4 rounded-md hover:bg-blue-600 transition-colors"
                  disabled={!text}
                >
                  Generate QR Code
                </button>
                {qrCodeUrl && (
                  <div className="flex justify-center">
                    <img src={qrCodeUrl} alt="QR Code" className="w-64 h-64" />
                  </div>
                )}
              </div>
            )}

            {activeTab === 'scan' && (
              <div>
                <div id="reader" className="w-full"></div>
              </div>
            )}

            {activeTab === 'history' && (
              <div className="space-y-4">
                {history.map((item) => (
                  <div
                    key={item.id}
                    className="flex items-center justify-between bg-gray-50 p-4 rounded-lg"
                  >
                    <div>
                      <div className="text-sm text-gray-500">
                        {item.type === 'generated' ? 'Generated' : 'Scanned'}
                      </div>
                      <div className="text-gray-900">{item.content}</div>
                      <div className="text-xs text-gray-500">
                        {new Date(item.timestamp).toLocaleString()}
                      </div>
                    </div>
                    <button
                      onClick={() => removeHistoryItem(item.id)}
                      className="text-gray-400 hover:text-gray-600"
                    >
                      <X className="w-5 h-5" />
                    </button>
                  </div>
                ))}
                {history.length === 0 && (
                  <div className="text-center text-gray-500">No history yet</div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;