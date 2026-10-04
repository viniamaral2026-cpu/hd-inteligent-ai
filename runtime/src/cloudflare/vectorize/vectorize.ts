/**
 * Vectorize Integration for NoteAgents Knowledge Studio + RAG
 * Busca semântica, embeddings e recuperação de contexto
 */
export interface VectorizeConfig {
  indexName: string;
  namespace: string;
  embeddingModel: string;
  metadataPrefix?: string;
}

export interface EmbeddingVector {
  id: string;
  values: number[];
  metadata: Record<string, any>;
  createdAt: string;
}

export interface SearchResult {
  id: string;
  score: number;
  metadata: Record<string, any>;
  excerpt: string;
}

export class Vectorize {
  private readonly cfAccountId: string;
  private readonly apiToken: string;
  private readonly config: VectorizeConfig;

  constructor(cfAccountId: string, apiToken: string, config: VectorizeConfig) {
    this.cfAccountId = cfAccountId;
    this.apiToken = apiToken;
    this.config = config;

    if (!cfAccountId || !apiToken) {
      throw new Error('Cloudflare Vectorize credentials required');
    }
  }

/**
     * Gerar embedding para texto
     */
    async embed(text: string): Promise<EmbeddingVector> {
      const response = await fetch(
        `https://api.cloudflare.com/client/v4/accounts/${this.cfAccountId}/ai/run/${this.config.embeddingModel}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.apiToken}`
          },
          body: JSON.stringify({ text })
        }
      );

      if (!response.ok) {
        throw new Error('Failed to generate embedding');
      }

      return (await response.json()) as EmbeddingVector;
    }

  /**
   * Inserir vetor no índice
   */
  async upsert(vector: EmbeddingVector): Promise<void> {
    const response = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${this.cfAccountId}/vector/${this.config.indexName}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiToken}`
        },
        body: JSON.stringify(vector)
      }
    );

    if (!response.ok) {
      throw new Error('Failed to upsert vector');
    }
  }

/**
     * Busca semântica
     */
    async search(query: string, topK: number = 5): Promise<SearchResult[]> {
      // Primeiro gerar embedding da query
      const queryEmbedding = await this.embed(query);

      const response = await fetch(
        `https://api.cloudflare.com/client/v4/accounts/${this.cfAccountId}/vector/${this.config.indexName}/query`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.apiToken}`
          },
          body: JSON.stringify({
            vector: queryEmbedding.values,
            topK,
            filter: {
              namespace: this.config.namespace
            }
          })
        }
      );

      if (!response.ok) {
        throw new Error('Failed to search vectors');
      }

      return (await response.json()) as SearchResult[];
    }

  /**
   * Delete vetor
   */
  async delete(id: string): Promise<void> {
    const response = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${this.cfAccountId}/vector/${this.config.indexName}/${id}`,
      {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiToken}`
        }
      }
    );

    if (!response.ok) {
      throw new Error('Failed to delete vector');
    }
  }

  /**
   * Listar todos os vetores (com paginação)
   */
  async list(): Promise<EmbeddingVector[]> {
    const response = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${this.cfAccountId}/vector/${this.config.indexName}`,
      {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiToken}`
        }
      }
    );

    if (!response.ok) {
      throw new Error('Failed to list vectors');
    }

    return (await response.json()) as EmbeddingVector[];
  }
}