using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Financeiro.Application.DTOs.Cliente
{
    public class ClientePostDTO
    {
        [Required(ErrorMessage = "O campo Nome é obrigatório.")]
        [MaxLength(200, ErrorMessage = "O campo Nome deve ter no máximo 200 caracteres.")]
        public string Nome { get; set; }
        [Required(ErrorMessage = "O campo Cpf é obrigatório.")]
        [MaxLength(11, ErrorMessage = "O campo Cpf deve ter no máximo 11 caracteres.")]
        public string Cpf { get; set; }
        [Required(ErrorMessage = "O campo Email é obrigatório.")]
        [EmailAddress(ErrorMessage = "O campo Email deve ser um endereço de email válido.")]
        public string Email { get; set; }
        [Required(ErrorMessage = "O campo Telefone é obrigatório.")]
        [MaxLength(20, ErrorMessage = "O campo Telefone deve ter no máximo 20 caracteres.")]
        public string Telefone { get; set; }
    }
}
