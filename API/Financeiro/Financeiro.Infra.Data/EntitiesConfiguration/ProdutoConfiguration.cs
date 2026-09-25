using Financeiro.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Data.EntitiesConfiguration
{
    public class ProdutoConfiguration : IEntityTypeConfiguration<Produto>
    {
        public void Configure(EntityTypeBuilder<Produto> builder)
        {
            builder.HasKey(p => p.Id);
            builder.Property(p => p.Nome)
                .IsRequired()
                .HasMaxLength(200);
            builder.Property(p => p.Preco)
                .IsRequired()
                .HasPrecision(18, 4)
                .HasDefaultValue(0);
            builder.Property(p => p.QuantidadeEstoque)
                .IsRequired()
                .HasDefaultValue(0);
            builder.HasIndex(p => p.Nome)
                .HasDatabaseName("IDX_PRODUTO_NOME");
            builder.HasMany(p => p.VendaItens)
                .WithOne(vi => vi.Produto)
                .HasForeignKey(vi => vi.ProdutoId);

        }
    }
}
