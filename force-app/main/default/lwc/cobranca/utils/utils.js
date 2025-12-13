// utils/utils.js

export function formatarValor(valor) {
    const numero = Number(valor);
    if (valor == null || isNaN(numero)) return 'Erro';
    return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(numero);
}

export function formatarDataBrasileira(data) {

    if (!data || data === 'Não encontrado' || data === null || data === undefined) {
        return 'Não encontrado';
    }

    try {
        // Se a data já estiver no formato correto, retorna como está
        if (typeof data === 'string' && data.match(/^\d{2}\/\d{2}\/\d{4}$/)) {
            return data;
        }

        // Converte para objeto Date
        let dateObj;

        if (typeof data === 'string') {
            // Se for string, pode estar em formato ISO (YYYY-MM-DD) ou outro formato
            dateObj = new Date(data);
        } else if (data instanceof Date) {
            dateObj = data;
        } else {
            // Tenta converter outros tipos
            dateObj = new Date(data);
        }

        // Verifica se é uma data válida
        if (isNaN(dateObj.getTime())) {
            return 'Data inválida';
        }

        // Formata para dd/MM/YYYY
        const dia = String(dateObj.getDate()).padStart(2, '0');
        const mes = String(dateObj.getMonth() + 1).padStart(2, '0'); // getMonth() retorna 0-11
        const ano = dateObj.getFullYear();

        return `${dia}/${mes}/${ano}`;
    } catch (error) {
        console.error('Erro ao formatar data:', error);
        return 'Erro na data';
    }
}

export async function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
export function formatarMoeda(valor) {
    return valor.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL"
    });
}

export function formatarPercentual(valor) {
    return valor.toLocaleString("pt-BR", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
}



export function validaNumero(number) {
    if (!number) return false;

    // Remove espaços extras
    const numeroLimpo = number.trim();

    // Regex aceita:
    // 1. (XX) XXXX-XXXX
    // 2. (XX) XXXXX-XXXX
    // 3. XXXXXXXXXXX (somente números, 10 ou 11 dígitos)
    const regex = /^(\(\d{2}\)\s\d{4,5}-\d{4}|\d{10,11})$/;

    return regex.test(numeroLimpo);
}


/**
  Trata número: remove símbolos, coloca +55 na frente
  e adiciona o 9 depois do DDD se tiver apenas 8 dígitos.
  
  Exemplos:
  (65) 8170-0029 → +5565981700029
 (11) 91234-5678 → +5511912345678
  62993777353 → +5562993777353
  65981700029 → +5565981700029
  +5565993777353 → +5565993777353
 */
export async function trataNumero(number) {
    if (!number) return '';

    // Remove tudo que não for número
    let numeros = number.replace(/\D/g, '');

    // Remove prefixo 55 se já tiver
    if (numeros.startsWith('55')) {
        numeros = numeros.substring(2);
    }

    // Agora esperamos só DDD + telefone
    let ddd = numeros.substring(0, 2);
    let telefone = numeros.substring(2);

    // Se telefone tiver 8 dígitos, adiciona 9 na frente
    if (telefone.length === 8) {
        telefone = '9' + telefone;
    }

    // Se telefone tiver mais de 9 dígitos, assume que já tem o 9
    // Corrige casos onde o número está errado
    if (telefone.length < 9 || telefone.length > 9) {
        // Tenta forçar o ajuste correto — opcional:
        telefone = telefone.slice(-9); // pega os 9 últimos dígitos
    }

    // Retorna no formato internacional
    return `+55${ddd}${telefone}`;
}





//Correção dias uteis parcelas de acordo
export function gerarFeriadosNacionais(ano) {
    const pascoa = calcularPascoa(ano);

    // Feriados móveis a partir da Páscoa
    const carnaval = new Date(pascoa);
    carnaval.setDate(pascoa.getDate() - 47);

    const sextaSanta = new Date(pascoa);
    sextaSanta.setDate(pascoa.getDate() - 2);

    const corpusChristi = new Date(pascoa);
    corpusChristi.setDate(pascoa.getDate() + 60);

    // Feriados fixos
    const feriadosFixos = [
        new Date(ano, 0, 1),   // 01/01 - Confraternização Universal
        new Date(ano, 3, 21),  // 21/04 - Tiradentes
        new Date(ano, 4, 1),   // 01/05 - Dia do Trabalho
        new Date(ano, 8, 7),   // 07/09 - Independência
        new Date(ano, 9, 12),  // 12/10 - Nossa Senhora Aparecida
        new Date(ano, 10, 2),  // 02/11 - Finados
        new Date(ano, 10, 15), // 15/11 - Proclamação da República
        new Date(ano, 11, 25), // 25/12 - Natal
    ];

    return [
        ...feriadosFixos,
        carnaval,
        sextaSanta,
        pascoa,
        corpusChristi
    ].map(d => d.toDateString()); // normaliza formato
}
// Cálculo da data da Páscoa (algoritmo de Gauss)
function calcularPascoa(ano) {
    const a = ano % 19;
    const b = Math.floor(ano / 100);
    const c = ano % 100;
    const d = Math.floor(b / 4);
    const e = b % 4;
    const f = Math.floor((b + 8) / 25);
    const g = Math.floor((b - f + 1) / 3);
    const h = (19 * a + b - d - g + 15) % 30;
    const i = Math.floor(c / 4);
    const k = c % 4;
    const l = (32 + 2 * e + 2 * i - h - k) % 7;
    const m = Math.floor((a + 11 * h + 22 * l) / 451);
    const mes = Math.floor((h + l - 7 * m + 114) / 31);
    const dia = ((h + l - 7 * m + 114) % 31) + 1;
    return new Date(ano, mes - 1, dia); // mês começa em 0
}
export function ajustarParaDiaUtil(data, feriados) {
    let reajustada = false;

    while (true) {
        const diaSemana = data.getDay(); // 0 = domingo, 6 = sábado
        const dataStr = data.toDateString();

        if (diaSemana === 6) {
            data.setDate(data.getDate() + 2); // sábado → segunda
            reajustada = true;
        } else if (diaSemana === 0) {
            data.setDate(data.getDate() + 1); // domingo → segunda
            reajustada = true;
        } else if (feriados.includes(dataStr)) {
            data.setDate(data.getDate() + 1); // feriado → próximo dia
            reajustada = true;
        } else {
            break; // achou dia útil
        }
    }

    return { data, reajustada };
}

// Função para criar data local (evita problema de fuso)
export function parseDataLocal(str) {
    const [ano, mes, dia] = str.split('-');
    return new Date(ano, mes - 1, dia);
}

export function formatarDataHora(dateValue) {
    if (!dateValue) return 'Não encontrado';

    const dataObj = new Date(dateValue);

    if (isNaN(dataObj.getTime())) {
        return 'Não encontrado';
    }

    const dia = String(dataObj.getDate()).padStart(2, '0');
    const mes = String(dataObj.getMonth() + 1).padStart(2, '0');
    const ano = dataObj.getFullYear();
    const horas = String(dataObj.getHours()).padStart(2, '0');
    const minutos = String(dataObj.getMinutes()).padStart(2, '0');

    return `${dia}/${mes}/${ano} ${horas}:${minutos}`;
}
export function formatarDataISO(data) {
    if (!(data instanceof Date)) {
        data = new Date(data); // garante que seja Date
    }

    const ano = data.getFullYear();
    const mes = String(data.getMonth() + 1).padStart(2, '0'); // meses 0-11
    const dia = String(data.getDate()).padStart(2, '0');

    return `${ano}-${mes}-${dia}`;
}
export function formatarNumeroAmericano(valor) {
    // Mantém 2 casas decimais, ponto como separador
    return Number(valor.toFixed(2));
}

export function formatarNomeConta(conta) {
    if (!conta) {
        return '';
    }

    const ultimoContatoNome = conta.ultimo_contato_nome || '';
    const nomeConta = conta.Name || '';

    // Se o último contato não foi encontrado, retorna apenas o nome da conta
    if (ultimoContatoNome === 'Não encontrado' || !ultimoContatoNome) {
        return nomeConta;
    }

    // Extrair os três primeiros nomes da conta
    const tresPrimeirosNomesConta = extrairTresPrimeirosNomes(nomeConta);

    // Formatar: Nome do Contato | Três Primeiros Nomes da Conta
    return `${ultimoContatoNome} | ${tresPrimeirosNomesConta}`;
}
function extrairTresPrimeirosNomes(nomeCompleto) {
    if (!nomeCompleto || typeof nomeCompleto !== 'string') {
        return '';
    }

    // Regex para capturar palavras (letras, acentos, números)
    // Ignora conectores comuns como "de", "da", "do", "das", "dos", "e", "&"
    const conectores = /^(de|da|do|das|dos|e|&|com|para|por|em|na|no|nas|nos)$/i;

    const palavras = nomeCompleto
        .trim()
        .split(/\s+/) // Divide por espaços
        .filter(palavra => palavra.length > 0) // Remove strings vazias
        .filter(palavra => !conectores.test(palavra)); // Remove conectores

    // Pega as 3 primeiras palavras válidas
    const tresPrimeiros = palavras.slice(0, 3);

    return tresPrimeiros.join(' ');
}
export function base64ToBlob(base64, mimeType) {
    const byteCharacters = atob(base64);
    const byteNumbers = new Array(byteCharacters.length);

    for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
    }

    const byteArray = new Uint8Array(byteNumbers);
    return new Blob([byteArray], { type: mimeType });
}