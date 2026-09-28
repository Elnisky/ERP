using Financeiro.Application.DTOs.Cliente;
using Financeiro.Application.DTOs.Venda;
using Financeiro.Application.Exceptions;
using Financeiro.Application.Interfaces;
using Financeiro.Domain.Entities;
using Financeiro.Domain.Interfaces;
using System.Linq;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Application.Services
{
    public class ClienteService : IClienteService
    {
        private readonly IClienteRepository _clienteRepository;

        public ClienteService(IClienteRepository clienteRepository)
        {
            _clienteRepository = clienteRepository;
        }
        public async Task<ClienteGetDTO> AddAsync(ClientePostDTO clientePostDTO)
        {
            var cliente = new Cliente
            {
                Nome = clientePostDTO.Nome,
                Cpf = clientePostDTO.Cpf,
                Email = clientePostDTO.Email,
                Telefone = clientePostDTO.Telefone,
                DataCadastro = DateTime.Now
            };

            var createdCliente = await _clienteRepository.AddAsync(cliente);
            return new ClienteGetDTO
            {
                Id = createdCliente.Id,
                Nome = createdCliente.Nome,
                Cpf = createdCliente.Cpf,
                Email = createdCliente.Email,
                Telefone = createdCliente.Telefone,
                DataCadastro = createdCliente.DataCadastro
                ,Vendas = createdCliente.Vendas?.Select(v => new VendaGetDTO
                {
                    Id = v.Id,
                    CriadoEm = v.CriadoEm,
                    PagoEm = v.PagoEm,
                    ClienteId = v.ClienteId,
                    Status = v.Status,
                    Total = v.Total
                }).ToList()
            };
        }

        public async Task<ClienteGetDTO> DeleteAsync(int id)
        {
            var cliente = await _clienteRepository.GetByIdAsync(id);
            if (cliente == null)
                throw new NotFoundException("O cliente não foi encontrado.");

            var deletedCliente = await _clienteRepository.DeleteAsync(id);
            return new ClienteGetDTO
            {
                Id = deletedCliente.Id,
                Nome = deletedCliente.Nome,
                Email = deletedCliente.Email,
                Telefone = deletedCliente.Telefone
                ,Vendas = deletedCliente.Vendas?.Select(v => new VendaGetDTO
                {
                    Id = v.Id,
                    CriadoEm = v.CriadoEm,
                    PagoEm = v.PagoEm,
                    ClienteId = v.ClienteId,
                    Status = v.Status,
                    Total = v.Total
                }).ToList()
            };
        }

        public async Task<List<ClienteGetDTO>> GetAllAsync()
        {
            var clientes = await _clienteRepository.GetAllAsync();
            return clientes.Select(c => new ClienteGetDTO
            {
                Id = c.Id,
                Nome = c.Nome,
                Cpf = c.Cpf,
                Email = c.Email,
                Telefone = c.Telefone,
                DataCadastro = c.DataCadastro,
                Vendas = c.Vendas?.Select(v => new VendaGetDTO
                {
                    Id = v.Id,
                    CriadoEm = v.CriadoEm,
                    PagoEm = v.PagoEm,
                    ClienteId = v.ClienteId,
                    Status = v.Status,
                    Total = v.Total
                }).ToList()
            }).ToList();
        }

        public async Task<ClienteGetDTO> GetByIdAsync(int id)
        {
            var cliente = await _clienteRepository.GetByIdAsync(id);
            if (cliente == null)
                throw new NotFoundException("O cliente não foi encontrado.");

            return new ClienteGetDTO
            {
                Id = cliente.Id,
                Nome = cliente.Nome,
                Cpf = cliente.Cpf,
                Email = cliente.Email,
                Telefone = cliente.Telefone,
                DataCadastro = cliente.DataCadastro,
                Vendas = cliente.Vendas?.Select(v => new VendaGetDTO
                {
                    Id = v.Id,
                    CriadoEm = v.CriadoEm,
                    PagoEm = v.PagoEm,
                    ClienteId = v.ClienteId,
                    Status = v.Status,
                    Total = v.Total
                }).ToList()
            };
        }

        public async Task<ClienteGetDTO> UpdateAsync(ClientePutDTO clientePutDTO)
        {
            var cliente = await _clienteRepository.GetByIdAsync(clientePutDTO.Id);
            if (cliente == null)
                throw new NotFoundException("O cliente não foi encontrado.");

            cliente.Nome = clientePutDTO.Nome;
            cliente.Email = clientePutDTO.Email;
            cliente.Telefone = clientePutDTO.Telefone;

            var updatedCliente = await _clienteRepository.UpdateAsync(cliente);
            return new ClienteGetDTO
            {
                Id = updatedCliente.Id,
                Nome = updatedCliente.Nome,
                Email = updatedCliente.Email,
                Telefone = updatedCliente.Telefone
                ,Vendas = updatedCliente.Vendas?.Select(v => new VendaGetDTO
                {
                    Id = v.Id,
                    CriadoEm = v.CriadoEm,
                    PagoEm = v.PagoEm,
                    ClienteId = v.ClienteId,
                    Status = v.Status,
                    Total = v.Total
                }).ToList()
            };
        }
    }
}
