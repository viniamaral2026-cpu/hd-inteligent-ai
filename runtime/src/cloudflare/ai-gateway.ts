/**
 * AI Gateway Integration for NoteAgents
 * Unificado para 20+ provedores de IA com caching, rate limiting e fallbacks
 */
export interface ProviderConfig {
  apiKey: string;
  models: string[];
  defaultModel: string;
  temperature: number;
  maxTokens: number;
}

export interface AiGatewayConfig {
  gatewayId: string;
  defaultModel: string;
  providers: Record<string, ProviderConfig>;
  caching: {
    enabled: boolean;
    ttlSeconds: number;
    maxKeys: number;
  };
  rateLimiting: {
    enabled: boolean;
    requestsPerMinute: number;
    perUser: boolean;
  };
  fallbacks: {
    enabled: boolean;
    fallbackModels: string[];
  };
  spendLimits: {
    enabled: boolean;
    monthlyLimit: number;
    perUser: boolean;
    alerts: boolean;
  };
}

export interface AiGatewayResult {
  success: boolean;
  response: any;
  modelUsed: string;
  cached: boolean;
  latencyMs: number;
  tokensUsed: number;
  cost: number;
}

export class AiGateway {
  private config: AiGatewayConfig;
  private cache: Map<string, AiGatewayResult>;
  private rateLimiter: Map<string, number>;

  constructor(config: AiGatewayConfig) {
    this.config = config;
    this.cache = new Map();
    this.rateLimiter = new Map();
  }

  async send(
    provider: keyof AiGatewayConfig['providers'],
    prompt: string,
    context?: Record<string, unknown>
  ): Promise<AiGatewayResult> {
    const providerConfig = this.config.providers[provider];
    if (!providerConfig) throw new Error('Provider not configured');

    // Verificar cache
    const cacheKey = `${provider}:${prompt}`;
    if (this.config.caching.enabled) {
      const cached = this.cache.get(cacheKey);
      if (cached && Date.now() - cached.latencyMs < this.config.caching.ttlSeconds * 1000) {
        return { ...cached, cached: true };
      }
    }

    // Verificar rate limit
    if (!this.checkRateLimit(provider)) {
      throw new Error('Rate limit exceeded');
    }

    // Executar com fallback
    let lastResult: AiGatewayResult | null = null;
    const modelsToTry = [providerConfig.defaultModel, ...(this.config.fallbacks?.fallbackModels || [])];
    for (const model of modelsToTry) {
      try {
        const result = await this.executeModel(provider, model, prompt, context);
        if (this.config.caching.enabled && result.success) {
          this.cache.set(cacheKey, { ...result, latencyMs: Date.now() });
        }
        return result;
      } catch (error) {
        lastResult = null;
        continue;
      }
    }

    if (lastResult) throw lastResult;
    throw new Error('All models failed');
  }

  private checkRateLimit(provider: string): boolean {
    if (!this.config.rateLimiting.enabled) return true;
    const now = Date.now();
    const lastRequest = this.rateLimiter.get(provider) || 0;
    const minuteAgo = now - 60000;
    if (lastRequest < minuteAgo) {
      this.rateLimiter.set(provider, now);
      return true;
    }
    return (this.config.rateLimiting.requestsPerMinute as number) > 0;
  }

  private async executeModel(
    provider: string,
    model: string,
    prompt: string,
    context?: Record<string, unknown>
  ): Promise<AiGatewayResult> {
    // Esta método será implementado com bindings Workers AI
    // Aqui definimos a interface; a implementação real usa AI Gateway bindings
    throw new Error('Implementação via Workers AI bindings');
  }
}