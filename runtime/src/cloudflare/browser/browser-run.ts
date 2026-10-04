/**
 * Browser Run Integration for NoteAgents Vision
 * Screenshots, snapshots, content extraction e visual regression
 */
export interface ScreenshotOptions {
  fullPage: boolean;
  scale: 'css' | 'device';
  timeout: number;
}

export interface SnapshotResult {
  html: string;
  screenshot: string; // base64 encoded
  url: string;
  title: string;
}

export interface ScrapeOptions {
  selector: string;
  attribute?: string;
}

export class BrowserRun {
  private readonly endpoint: string;

  constructor(accountId: string, apiToken: string) {
    this.endpoint = `https://api.cloudflare.com/client/v4/accounts/${accountId}/browser`;

    // Validar credenciais básicas
    if (!accountId || !apiToken) {
      throw new Error('Cloudflare Browser credentials required');
    }
  }

  /**
   * Captura screenshot de página
   */
  async screenshot(url: string, options: ScreenshotOptions = { fullPage: false, scale: 'css', timeout: 30000 }): Promise<string> {
    const body = {
      url,
      fullPage: options.fullPage,
      scale: options.scale,
      timeout: options.timeout
    };

    const result = await this.fetchBrowserEndpoint('screenshot', body);
    return result.imageData || result.base64 || '';
  }

  /**
   * Captura HTML + screenshot em uma chamada
   */
  async snapshot(url: string, options: ScreenshotOptions = { fullPage: false, scale: 'css', timeout: 30000 }): Promise<SnapshotResult> {
    const body = {
      url,
      fullPage: options.fullPage,
      scale: options.scale,
      timeout: options.timeout
    };

    const result = await this.fetchBrowserEndpoint('snapshot', body);
    return {
      html: result.html || '',
      screenshot: result.imageData || result.base64 || '',
      url,
      title: result.title || ''
    };
  }

  /**
   * Extrair HTML da página renderizada
   */
  async content(url: string, options: ScreenshotOptions = { fullPage: true, scale: 'css', timeout: 30000 }): Promise<string> {
    const body = {
      url,
      fullPage: options.fullPage,
      scale: options.scale,
      timeout: options.timeout
    };

    const result = await this.fetchBrowserEndpoint('content', body);
    return result.html || '';
  }

  /**
   * Extrair elemento específico via seletor CSS
   */
  async scrape(url: string, options: ScrapeOptions): Promise<string> {
    const body = {
      url,
      selector: options.selector,
      attribute: options.attribute
    };

    const result = await this.fetchBrowserEndpoint('scrape', body);
    return result.content || result.text || '';
  }

  private async fetchBrowserEndpoint(endpoint: string, body: any): Promise<any> {
    const response = await fetch(`https://${this.endpoint}/${endpoint}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.getAuthToken()}`
      },
      body: JSON.stringify(body)
    });

    if (!response.ok) {
      const errorData = (await response.json()) as { errors?: Array<{ message: string }> };
      throw new Error(errorData.errors?.[0]?.message || 'Browser API error');
    }

    return response.json();
  }

  private getAuthToken(): string {
    // Em implementação real, isso viria do bindings Workers AI
    // Por enquanto, retornamos um placeholder
    return 'placeholder-token';
  }
}