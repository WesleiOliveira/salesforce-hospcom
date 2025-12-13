export const VALOR_MAXIMO_DESCONTO_JUROS = 50;//50%
export const VALOR_MAXIMO_DESCONTO_MULTA = 50;//50%
export const VALOR_MINIMO_ENTRADA = 0; //Não há mais valor minimo de entrada 
export const JUROS_DIARIO = 0.0833; //2.5% ao dia


export function valorMinimoEntrada(valor) {
    return Math.ceil(
        (VALOR_MINIMO_ENTRADA / 100) * valor
    );
}