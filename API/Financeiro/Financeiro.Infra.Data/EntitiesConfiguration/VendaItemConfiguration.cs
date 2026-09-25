using Financeiro.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Data.EntitiesConfiguration
{
    public class VendaItemConfiguration : IEntityTypeConfiguration<VendaItem>
    {
        public void Configure(EntityTypeBuilder<VendaItem> builder)
        {
            builder.HasKey(vi => vi.Id);
            builder.Property(vi => vi.VendaId)
                .IsRequired();
            builder.Property(vi => vi.ProdutoId)
                .IsRequired();
            builder.Property(vi => vi.Quantidade)
                .IsRequired()
                .HasDefaultValue(1);
            builder.Property(vi => vi.ValorUnitario)
                .IsRequired()
                .HasPrecision(18, 4)
                .HasDefaultValue(0);
            builder.Property(vi => vi.ValorTotal)
                .IsRequired()
                .HasPrecision(18, 4)
                .HasDefaultValue(0);
            builder.HasIndex(vi => vi.VendaId)
                .HasDatabaseName("IDX_VENDAITEM_VENDA");
            builder.HasIndex(vi => vi.ProdutoId)
                .HasDatabaseName("IDX_VENDAITEM_PRODUTO");
        }
    }
}